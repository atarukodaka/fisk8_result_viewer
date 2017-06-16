
module Fisk8ResultViewer
  module Updater
    class CompetitionUpdater
      class CategoryResultAdaptor
        def initialize(hash)
          cr = ::CategoryResult.new(hash)
          cr.skater_name = ::Skater.correct_name(cr.skater_name)
          cr.skater = ::Skater.find_or_create_by_isu_number_or_name(cr.isu_number, cr.skater_name) do |sk|
            sk.category = cr.category.seniorize
            sk.nation = cr.nation
          end
          cr.skater_name = cr.skater.name
          cr.save!
          @model = cr
        end
        def to_model
          @model
        end
      end
      ################################################################
      class ScoreAdaptor
        def initialize(hash)
          score = ::Score.new(hash.except(:elements, :components))
          score.skater_name = ::Skater.correct_name(score.skater_name)
          cr = score.competition.category_results.find_by(skater_name: score.skater_name) || raise
          score.skater = cr.skater
          score.skater_name = score.skater.name

          ActiveRecord::Base.transaction {
            cr.skater.scores << score
            cr.scores << score
            score.competition.scores << score

            hash[:elements].map {|e| score.elements.create(e)}
            hash[:components].map {|e| score.components.create(e)}
            score.save!                    
          }
          @model = score
        end
        def to_model
          @model
        end
      end
      ################################################################
      include Contracts
      
      DEFAULT_PARSER = :isu_generic
      ACCEPT_CATEGORIES =
        [
         :MEN, :LADIES, :PAIRS, :"ICE DANCE",
         :"JUNIOR MEN", :"JUNIOR LADIES", :"JUNIOR PAIRS", :"JUNIOR ICE DANCE",
        ]
      
      def initialize(accept_categories: nil)
        @accept_categories = accept_categories || ACCEPT_CATEGORIES
        @city_country = YAML.load_file(Rails.root.join('config', 'city_country.yml'))
      end
      
      Contract KeywordArgs[type: Or[Symbol, String, nil]] => ArrayOf[Hash]
      def load_competition_list(type: nil)
        fname = (type) ? "competitions_#{type}.yml" : "competitions.yml"
        yaml_filename = Rails.root.join('config', fname)
        YAML.load_file(yaml_filename).map do |item|
          case item
          when String
            {url: item, parser_type: DEFAULT_PARSER, }
          when Hash
            {
              url: item["url"],
              parser_type: item["parser"] || DEFAULT_PARSER,
              comment: item['comment'],
            }
          end
        end
      end
      def update_competition(url, parser_type: :isu_generic, comment: nil)
        if c = ::Competition.find_by(site_url: url)
          return c
        end
        
        ActiveRecord::Base.transaction do 
          puts ("*" * 100) + "\n** #{url}"
          parser = Parsers.get_parser(parser_type)
          competition_hash = parser.parse(:competition, url).merge({comment: comment})
          summary = Adaptor::CompetitionAdaptor.new(competition_hash)
          competition = summary.to_model
          competition.country ||= @city_country[competition.city]          
          puts " %s [%s] - %s" % [competition.name, competition.cid, competition.season]

          ## category
          summary.categories.each do |category|
            next if !@accept_categories.include?(category.to_sym)
            url = summary.result_url(category)
            parser.parse(:category_result, url).each do |result_hash|
              result_hash.update({category: category, competition: competition})
              CategoryResultAdaptor.new(result_hash).to_model.tap {|cr|
                puts cr.summary
              }
            end
            
            ## segment
            summary.segments(category).each do |segment|
              url = summary.score_url(category, segment)
              date = summary.starting_time(category, segment)
              parser.parse(:score, url).each do |score_hash|
                score_hash.update({ date: date, competition: competition, category: category, segment: segment})
                ScoreAdaptor.new(score_hash).to_model.tap {|score|
                  puts score.summary
                }
              end
            end ## segmnet
          end ## category
          competition
        end  ## transaction
      end  ## def
    end ## class
  end
end
