require 'fisk8viewer/competition_summary'
require 'fisk8viewer/parsers'
require 'fisk8viewer/parser'
require 'fisk8viewer/updater/find_skater'
require 'fisk8viewer/updater/category_accepter'

module Fisk8Viewer
  module Updater
    class CompetitionUpdater
      include Utils
      include FindSkater
      attr_reader :category_accepter
      
      DEFAULT_PARSER = :isu_generic

      def initialize(accept_categories: nil)
        @category_accepter = CategoryAccepter.new(accept_categories)
      end
      class << self
        def load_competition_list(yaml_filename)
          YAML.load_file(yaml_filename).map do |item|
            case item
            when String
              {url: item, parser: DEFAULT_PARSER}
            when Hash
              {url: item["url"], parser: item["parser"] || DEFAULT_PARSER, comment: item['comment']}
            else
              raise "invalid format ('#{yaml_filename}'): has to be String or Hash"
            end
          end
        end
      end
      ################
      def get_parser(parser_type)
        parser_klass = Fisk8Viewer::Parsers.registered[parser_type] || raise("no such parser: '#{parser_type}'")
        parser_klass.new
      end
      
      def update_competition(url, parser_type: :isu_generic, force: false, comment: nil)
        parser = get_parser(parser_type)
        puts "=" * 100
        puts "** update competition: #{url} with '#{parser_type}'"
        if (competitions = Competition.where(site_url: url)).present?
          if force
            puts "   destroy existing competitions (%d)" % [competitions.count]
            ActiveRecord::Base::transaction {  competitions.map(&:destroy) }
          else
            puts " !!  skip as it already exists"
            return competitions.first
          end
        end

        parsed = parser.parse_competition_summary(url)
        summary = Fisk8Viewer::CompetitionSummary.new(parsed)
        keys = [:name, :city, :country, :site_url, :start_date, :end_date, :season,]
        
        ActiveRecord::Base::transaction do
          competition = Competition.create(summary.slice(*keys)) do |comp|
            update_competition_identifers(comp)
            comp.comment = comment
          end
          ## for each categories
          summary.categories.each do |category|
            next unless category_accepter.accept?(category)
            result_url = summary.result_url(category)
            puts " = [%s]" % [category]
            update_category_results(result_url, competition: competition, parser: parser)

            ## for segments
            summary.segments(category).each do |segment|
              puts "  - [#{category}/#{segment}]"
              score_url = summary.score_url(category, segment)
              attrs = {date: summary.starting_time(category, segment)}
              update_scores(score_url, competition: competition, category: category,
                            segment: segment, parser: parser, attributes: attrs)
            end
          end
          competition
        end
      end
      def update_competition_identifers(competition)
        year = competition.start_date.try(:year)
        country = competition.country

        ary = case competition.name
              when /^ISU Grand Prix .*Final/, /^ISU GP.*Final/
                [:gp, "GPF#{year}"]
              when /^ISU GP/
                [:gp, "GP#{country}#{year}"]
              when /Olympic/
                [:olympic, "OLYMPIC#{year}"]
              when /^ISU World Figure/, /^ISU World Championships/
                [:world, "WORLD#{year}"]
              when /^ISU Four Continents/
                [:fcc, "FCC#{year}"]
              when /^ISU European/
                [:euro, "EURO#{year}"]
              when /^ISU World Team/
                [:team, "TEAM#{year}"]
              when /^ISU World Junior/
                [:jworld, "JWORLD#{year}"]
              when /^ISU JGP/, /^ISU Junior Grand Prix/
                [:jgp, "JGP#{country}#{year}"]
              when /^Finlandia Trophy/
                [:calendar, "B_FIN#{year}"]
              else
                [:unknown, competition.name.gsub(/\s+/, '_')]
              end
        competition.competition_type = ary[0]
        competition.cid = ary[1]
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

        result_hash[:skater_name] = correct_skater_name(result_hash[:skater_name])
        puts "   %<ranking>2d: '%{skater_name}' (%{isu_number}) [%{nation}] %{short_ranking} / %{free_ranking}" % result_hash
        cr.attributes = result_hash.slice(*keys)

        skater = find_or_create_skater(result_hash[:isu_number], result_hash[:skater_name], category: result_hash[:category], nation: result_hash[:nation])
        cr.skater = skater
        skater.category_results << cr

        cr.save!
        cr
      end
      ################################################################
=begin
      def find_relevant_category_result(competition:, category:, segment:, skater_name:, ranking: )
        ## find relevant category result
        results = competition.category_results
        results.find_by(category: category, skater_name: skater_name) || raise
        ## for fcc2012 ladies short
          ## name on category result and scores are different.
          case segment
          when /^SHORT/
            results.find_by(category: category, short_ranking: ranking)
          when /^FREE/
            results.find_by(category: category, free_ranking: ranking)
          end || raise

      end
=end
      def update_scores(score_url, parser:,competition:, category:, segment:, attributes: {})
        parser.parse_score(score_url).each do |score_hash|
          score_hash[:skater_name] = correct_skater_name(score_hash[:skater_name])
          #cr = find_relevant_category_result(competition: competition, category: category, segment: segment, skater_name: score_hash[:skater_name], ranking: score_hash[:ranking])
          #raise if cr.nil?
          cr = competition.category_results.find_by(category: category, skater_name: score_hash[:skater_name]) || raise
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
                      :result_pdf, :tss, :tes, :pcs, :deductions, :base_value]

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
      def update_sid(_score_hash, score)
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
