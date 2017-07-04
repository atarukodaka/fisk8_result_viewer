using Seniorize

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
      
      def initialize(accept_categories: nil, quiet: false)
        @accept_categories = accept_categories || ACCEPT_CATEGORIES
        @city_country = YAML.load_file(Rails.root.join('config', 'city_country.yml'))
        @quiet = quiet
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
          dputs ("*" * 100) + "\n** #{url}"
          parser = Parsers.get_parser(parser_type)
          competition_hash = parser.parse(:competition, url)
          summary = Adaptor::CompetitionAdaptor.new(competition_hash)
          competition = summary.to_model
          competition.comment = comment
          competition.country ||= @city_country[competition.city]
          competition.save!
          dputs " %s [%s] - %s" % [competition.name, competition.short_name, competition.season]

          ## category
          summary.categories.each do |category|
            next if !@accept_categories.include?(category.to_sym)
            url = summary.result_url(category)
            parser.parse(:category_result, url).each do |result_hash|
              #CategoryResult.create(result_hash) do |cr|
              CategoryResult.create_from_hash(result_hash) do |cr|
                cr.competition = competition
                cr.category = category
                #cr.skater_name = Skater.correct_name(result_hash[:skater_name])
                cr.skater = Skater.find_or_create_by_isu_number_or_name(cr.isu_number, Skater.correct_name(result_hash[:skater_name])) do |sk|
                  sk.attributes = {
                    category: category.seniorize,
                    nation: result_hash[:nation],
                  }
                end
                dputs cr.summary
              end
            end
            
            ## segment
            summary.segments(category).each do |segment|
              url = summary.score_url(category, segment)
              date = summary.starting_time(category, segment)
              parser.parse(:score, url).each do |score_hash|
                cr = competition.category_results.search_by_skater_name_or_segment_ranking(skater_name: Skater.correct_name(score_hash[:skater_name]), segment: segment, ranking: score_hash[:ranking]).first || raise
                ActiveRecord::Base.transaction do
                  score = Score.create_from_hash(score_hash)
                  score.update!(
                                competition: competition,
                                date: date,
                                category: category,
                                segment: segment,
                                category_result: cr,
                                skater: cr.skater,
                                )
                  score_hash[:elements].map {|e|
                    score.elements.create(e) do |element|
                      element.element_type = Element.parse_element_type(element.name, category)
                    end
                  }
                  score_hash[:components].map {|e| score.components.create(e)}
                  dputs score.summary
                end
              end
            end ## segmnet
          end ## category
          competition
        end  ## transaction
      end  ## def

      private
      def dputs(*args)
        puts args unless @quiet
      end
    end ## class
  end
end
