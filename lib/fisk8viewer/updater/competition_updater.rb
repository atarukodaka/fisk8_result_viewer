require 'fisk8viewer/competition_summary'
require 'fisk8viewer/parsers'
require 'fisk8viewer/parser'
require 'fisk8viewer/updater/find_skater'

module Fisk8Viewer
  module Updater
    class CompetitionUpdater
      include Utils
      include FindSkater
      attr_reader :accept_categories

      DEFAULT_PARSER = :isu_generic
      ACCEPT_CATEGORIES =
        [:MEN, :LADIES, :PAIRS, :"ICE DANCE",
         :"JUNIOR MEN", :"JUNIOR LADIES", :"JUNIOR PAIRS", :"JUNIOR ICE DANCE",
        ]

      def initialize(accept_categories: nil, force: nil)
        @accept_categories =
          case accept_categories
          when String
            accept_categories.split(/ *, */).map(&:upcase).map(&:to_sym)
          when Array
            accept_categories.map(&:to_sym)
          else
            accept_categories
          end || ACCEPT_CATEGORIES

        @force = force
      end
      class << self
        def load_competition_list(yaml_filename)
          YAML.load_file(yaml_filename).map do |item|
            case item
            when String
              {url: item, parser: DEFAULT_PARSER}
            when Hash
              {url: item["url"], parser: item["parser"]}
            else
              raise "invalid format ('#{yaml_filename}'): has to be String or Hash"
            end
          end
        end
      end
      def accept_category?(category)
        return true if @accept_categories.nil?
        @accept_categories.include?(category.to_sym)
      end
      ################
      def get_parser(parser_type)
        parser_klass = Fisk8Viewer::Parsers.registered[parser_type]
        raise "no such parser: '#{parser_type}'" if parser_klass.nil?

        parser_klass.new
      end
      def update_competition(url, parser_type: :isu_generic)
        parser = get_parser(parser_type)
        puts "=" * 100
        puts "** update competition: #{url} with '#{parser_type}'"
        
        if (competitions = Competition.where(site_url: url)).present?
          if @force
            puts "   destroy existing competitions (%d)" % [competitions.count]
            ActiveRecord::Base::transaction do
              competitions.map(&:destroy)
            end
          else
            puts " !!  skip as it already exists"
            return
          end
        end
        
        ActiveRecord::Base::transaction do
          parsed = parser.parse_competition_summary(url)
          summary = Fisk8Viewer::CompetitionSummary.new(parsed)
          keys = [:name, :city, :country, :site_url, :start_date, :end_date,
                  :season,]

          competition = Competition.create(summary.slice(*keys))
          ## competition_type, cid
          competition.update!(competition_type: get_competition_type(competition))
          competition.update!(cid: get_cid(competition))

          ## for each categories
          summary.categories.each do |category|
            next unless accept_category?(category)
            
            result_url = summary.result_url(category)
            puts " = [%s]" % [category]
            update_category_results(result_url, competition: competition, parser: parser)

            ## for segments
            summary.segments(category).each do |segment|
              puts "  - [#{category}/#{segment}]"

              score_url = summary.score_url(category, segment)
              attrs = {date: summary.starting_time(category, segment)}
              update_scores(score_url, competition: competition, category: category, segment: segment, parser: parser, attributes: attrs)
            end
          end
        end
      end
      def get_competition_type(competition)
        case competition.name
        when /^ISU GP/, /^ISU Grand Prix/
          :gp
        when /Olympic/
          :olympic
        when /^ISU World Figure/, /^ISU World Championships/
          :world
        when /^ISU Four Continents/
          :fcc
        when /^ISU European/
          :europe
        when /^ISU World Team/
          :team
        when /^ISU World Junior/
          :jworld
        when /^ISU JGP/, /^ISU Junior Grand Prix/
          :jgp
        else
          :unknown
        end
      end
      def get_cid(competition)
        name = competition.name
        year = competition.start_date.try(:year)
        city = competition.city
        country = competition.country

        case competition.competition_type.to_sym
        when :olympic
          "OLYMPIC#{year}"
        when :gp
          if competition.name =~ /Final/
            "GPF#{year}"
          else
            "GP#{country}#{year}"
          end
        when :world
          "WORLD#{year}"
        when :fcc
          "4CC#{year}"
        when :europe
          "EURO#{year}"
        when :team
          "TEAM#{year}"
        when :jworld
          "JWORLD#{year}"
        when :jgp
          "JGP#{country.presence || city}#{year}"
        else
          competition.name.to_s.gsub(/Figure Skating */, '').gsub(/\s/, '_')
        end
        ## TODO: UNIQ CHECK
      end

      ################################################################
      def update_category_results(url, competition:, parser: )
        return [] if url.blank?

        parser.parse_category_result(url).map do |result_hash|
          competition.category_results.create do |cr|
            cr.competition_name = competition.name
            update_category_result(result_hash, cr)
          end
        end
      end
      def update_category_result(result_hash, cr)
        keys = [:category, :ranking, :skater_name, :nation, :points, :short_ranking, :free_ranking]
        puts "   %<ranking>2d: '%{skater_name}' (%{isu_number}) [%{nation}] %{short_ranking} / %{free_ranking}" % result_hash
        cr.attributes = result_hash.slice(*keys)

        skater = find_or_create_skater(result_hash[:isu_number], result_hash[:skater_name], category: result_hash[:category], nation: result_hash[:nation])
        cr.skater = skater
        skater.category_results << cr

        cr.save!
        cr
      end
      ################################################################
      def find_relevant_category_result(competition:, category:, segment:, skater_name:, ranking: )
        ## find relevant category result
        results = competition.category_results
        results.find_by(category: category, skater_name: skater_name) ||
          case segment
          when /^SHORT/
            cr = results.find_by(category: category, short_ranking: ranking)
          when /^FREE/
            cr = results.find_by(category: category, free_ranking: ranking)
          end || raise
      end
      def update_scores(score_url, parser:,competition:, category:, segment:, attributes: {})
        parser.parse_score(score_url).each do |score_hash|
          cr = find_relevant_category_result(competition: competition, category: category, segment: segment, skater_name: score_hash[:skater_name], ranking: score_hash[:ranking])
          raise if cr.nil?
          skater = cr.skater
          
          score = competition.scores.create do |sc|
            sc.competition_name = competition.name
            sc.category = category
            sc.segment = segment
            sc.skater = skater
            sc.attributes = attributes
          end
          skater.scores << score
          cr.scores << score if cr

          update_score(score_hash, score)
        end
      end
      def update_score(score_hash, score)
        ## skater
        puts "    %<ranking>2d: '%{skater_name}' (%{nation}) %<tss>3.2f" % score_hash
        score_keys = [:skater_name, :ranking, :starting_number, :nation,
                      :result_pdf, :tss, :tes, :pcs, :deductions]

        score.attributes = score_hash.slice(*score_keys)
        score.save!
        update_elements(score_hash, score)
        update_components(score_hash, score)
        update_sid(score_hash, score)
      end
      def update_elements(score_hash, score)
        ## technical elements
        ActiveRecord::Base.transaction do
          element_keys = [:number, :element, :info, :base_value, :credit, :goe, :judges, :value]
          elem_summary = []
          score_hash[:elements].each do |element|
            score.elements.create!(element.slice(*element_keys))
            elem_summary << element[:element]
          end
          score.update!(elements_summary: elem_summary.join('/'))
        end
      end
      def update_components(score_hash, score)
        ## components
        ActiveRecord::Base.transaction do
          comp_keys = [:component, :number, :factor, :judges, :value]
          comp_summary = []
          score_hash[:components].each do |comp|
            score.components.create!(comp.slice(*comp_keys))
            comp_summary << comp[:value]
          end
          score.update!(components_summary: comp_summary.join('/'))
        end
      end
      def update_sid(score_has, score)
        category_abbr = score.category || ""
        [["MEN", "M"], ["LADIES", "L"], ["PAIRS", "P"], ["ICE DANCE", "D"], ["JUNIOR ", "J"]].each do |ary|
          category_abbr = category_abbr.gsub(ary[0], ary[1])
        end

        segment_abbr =score.segment || ""
        segment_abbr = segment_abbr.split(/ /).map {|d| d[0]}.join

        score.update!(sid: [score.competition.cid, category_abbr, segment_abbr, score.ranking].join('-'))
      end
    end  ## class
  end
end
