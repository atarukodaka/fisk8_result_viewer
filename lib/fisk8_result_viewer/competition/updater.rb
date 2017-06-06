
module Fisk8ResultViewer
  module Competition
    class Updater
      include Contracts
      
      DEFAULT_PARSER = :isu_generic

      def initialize
        @city_country = YAML.load_file(Rails.root.join('config', 'city_country.yml'))
      end
      Contract Or[String,Pathname] => ArrayOf[Hash]
      def load_competition_list(yaml_filename)
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
      def update_competition(url, parser_type: :isu_generic, comment: nil, accept_categories: nil)
        accept_categories ||=
          [
           :MEN, :LADIES, :PAIRS, :"ICE DANCE",
           :"JUNIOR MEN", :"JUNIOR LADIES", :"JUNIOR PAIRS", :"JUNIOR ICE DANCE",
          ]
                               
        ActiveRecord::Base.transaction do 
          ::Competition.find_or_create_by(site_url: url) do |competition|
            puts "*" * 100
            puts "** #{url}"
            parser = Fisk8ResultViewer::Parsers.get_parser(:competition, parser_type)
            summary = CompetitionSummary.new(parser.parse_competition(url))

            keys = [:site_url, :name, :city, :country, :start_date, :end_date, :season, ]
            competition.attributes = summary.slice(*keys)
            competition.attributes = get_identifers(competition.name, competition.country, competition.city, competition.start_date.year)
            competition.country ||= @city_country[competition.city]
            competition.save!
            puts " %s [%s] - %s" % [competition.name, competition.cid, competition.season]

            ## category
            summary.categories.each do |category|
              next if (!accept_categories.nil?) && (!accept_categories.include?(category.to_sym))
              url = summary.result_url(category)
              cr_parser = Parsers.get_parser(:category_result, parser_type)
              cr_updater = Fisk8ResultViewer::CategoryResult::Updater.new
              cr_updater.update_category_results(url, competition, category, parser: cr_parser)

              ## segment
              summary.segments(category).each do |segment|
                url = summary.score_url(category, segment)
                score_parser = Parsers.get_parser(:score, parser_type)
                score_updater = Fisk8ResultViewer::Score::Updater.new
                score = score_updater.update_scores(url, competition, category, segment, parser: score_parser, attributes: {date: summary.starting_time(category, segment)})
              end
            end
          end
        end  ## transaction
      end
      
      private
      # rubocop:disable all
      def get_identifers(name, country, city, year)
        #year = competition.start_date.year
        #country = competition.country || competition.city.to_s.upcase.gsub(/\s+/, '_')
        country ||= city.to_s.upcase.gsub(/\s+/, '_')        

        ary = case name
              when /^ISU Grand Prix .*Final/, /^ISU GP.*Final/
                [:gp, "GPF#{year}", true]
              when /^ISU GP/
                [:gp, "GP#{country}#{year}", true]
              when /Olympic/
                [:olympic, "OLYMPIC#{year}", true]
              when /^ISU World Figure/, /^ISU World Championships/
                [:world, "WORLD#{year}", true]
              when /^ISU Four Continents/
                [:fcc, "FCC#{year}", true]
              when /^ISU European/
                [:euro, "EURO#{year}", true]
              when /^ISU World Team/
                [:team, "TEAM#{year}", true]
              when /^ISU World Junior/
                [:jworld, "JWORLD#{year}", true]
              when /^ISU JGP/, /^ISU Junior Grand Prix/
                [:jgp, "JGP#{country}#{year}", true]
                
              when /^Finlandia Trophy/
                [:challenger, "FINLANDIA#{year}", false]
              when /Warsaw Cup/
                [:challenger, "WARSAW#{year}", false]
              when /Autumn Classic/
                [:challenger, "ACI#{year}", false]
              when /Nebelhorn/
                [:challenger, "NEBELHORN#{year}", false]
              when /Lombardia/
                [:challenger, "LOMBARDIA#{year}", false]
              when /Ondrej Nepela/
                [:challenger, "NEPELA#{year}", false]
              else
                [:unknown, name.gsub(/\s+/, '_'), false]
              end
        {
          competition_type: ary[0],
          cid: ary[1],
          isu_championships: ary[2],
        }
      end
      # rubocop:enable all
    end ## class
  end
end
