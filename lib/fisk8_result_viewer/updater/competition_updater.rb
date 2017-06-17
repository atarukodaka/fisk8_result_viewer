
module Fisk8ResultViewer
  module Updater
    class CompetitionUpdater
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
          competition_hash = parser.parse(:competition, url)
          summary = Adaptor::CompetitionAdaptor.new(competition_hash)
          competition = summary.to_model
          competition.comment = comment
          competition.country ||= @city_country[competition.city]
          competition.save!
          puts " %s [%s] - %s" % [competition.name, competition.short_name, competition.season]

          ## category
          summary.categories.each do |category|
            next if !@accept_categories.include?(category.to_sym)
            url = summary.result_url(category)
            parser.parse(:category_result, url).each do |result_hash|
              result_hash.update({category: category, competition: competition})
              Adaptor::CategoryResultAdaptor.new(result_hash).to_model.tap {|cr|
                cr.save!
                puts cr.summary
              }
            end
            
            ## segment
            summary.segments(category).each do |segment|
              url = summary.score_url(category, segment)
              date = summary.starting_time(category, segment)
              parser.parse(:score, url).each do |score_hash|
                score_hash.update({ date: date, competition: competition, category: category, segment: segment})
                Adaptor::ScoreAdaptor.new(score_hash).to_model.tap {|score|
                  score.save!
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
