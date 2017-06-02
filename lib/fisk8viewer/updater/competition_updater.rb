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
        @city_country = YAML.load_file(Rails.root.join('config', 'city_country.yml'))
      end
      class << self
        def load_competition_list(yaml_filename)
          YAML.load_file(yaml_filename).map do |item|
            case item
            when String
              {url: item, parser: DEFAULT_PARSER, }
            when Hash
              {
                url: item["url"], parser: item["parser"] || DEFAULT_PARSER,
                comment: item['comment'],
              }.deep_symbolize_keys
            else
              raise "invalid format ('#{yaml_filename}'): has to be String or Hash"
            end
          end
        end
      end
      ################
      def get_parser(parser_type)
        #parser_klass = Fisk8Viewer::Parsers.registered[parser_type] || raise("no such parser: '#{parser_type}'")
        #parser_klass.new
        Fisk8Viewer::Parsers.registered[parser_type].try(:new) || raise("no such parser: '#{parser_type}'")
      end

      def destroy_existing_competitions(url)
        ActiveRecord::Base::transaction {
          Competition.where(site_url: url).map(&:destroy)
        }
      end
      def update_competition(url, parser_type: :isu_generic, comment: nil)
        parser = get_parser(parser_type)
        puts "=" * 100
        puts "** update competition: #{url} with '#{parser_type}'"
        if c = Competition.find_by(site_url: url); return c;   end
        
        summary = Fisk8Viewer::CompetitionSummary.new(parser.parse_competition_summary(url))
        keys = [:name, :city, :country, :site_url, :start_date, :end_date, :season,]

        ActiveRecord::Base::transaction do
          competition = Competition.create(summary.slice(*keys)) do |comp|
            comp[:country] ||= @city_country[comp.city]
            comp[:comment] = comment if comment
            update_competition_identifers(comp)
          end
          ## for each categories
          puts "  existing categories : #{summary.categories.join(', ')}"
          summary.categories.each do |category|
            next unless category_accepter.accept?(category)
            result_url = summary.result_url(category)
            puts " = [%s]" % [category]
            update_category_results(result_url, competition: competition, parser: parser,
                                    category: category)

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
      # rubocup:disable all
      def update_competition_identifers(competition)
        year = competition.start_date.try(:year)
        country = competition.country || competition.city.upcase.gsub(/\s+/, '_')

        ary = case competition.name
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
                [:unknown, competition.name.gsub(/\s+/, '_'), false]
              end
        competition.attributes = {
          competition_type: ary[0],
          cid: ary[1],
          isu_championships: ary[2],
        }
      end
      # rubocup:enable all
      ################################################################
      def update_category_results(url, competition:, parser: , category: )
        return [] if url.blank?
        parser.parse_category_result(url).map do |result_hash|
          competition.category_results.create do |cr|
            cr.competition_name = competition.name
            cr.category = category
            update_category_result(result_hash, cr)
          end
        end
      end
      def update_category_result(result_hash, cr)
        keys = [:ranking, :skater_name, :nation, :points, :short_ranking, :free_ranking]

        result_hash[:skater_name] = correct_skater_name(result_hash[:skater_name])
        cr.attributes = result_hash.slice(*keys)

        skater = find_or_create_skater(result_hash[:isu_number], result_hash[:skater_name], category: cr.category, nation: result_hash[:nation])
        cr.skater = skater
        puts "   #{cr.ranking}: '#{cr.skater_name}' (#{cr.skater.isu_number}) [#{cr.nation}] #{cr.short_ranking} / #{cr.free_ranking}"
        skater.category_results << cr
      end
      def find_relevant_category_result(category_results, skater_name, segment, ranking)
        ranking_type = (segment =~ /^SHORT/) ? :short_ranking : :free_ranking
        category_results.find_by(skater_name: skater_name) ||
          category_results.where(ranking_type => ranking).first
      end
      ################################################################
      def update_scores(score_url, parser:,competition:, category:, segment:, attributes: {})
        parser.parse_score(score_url).each do |score_hash|
          score_hash[:skater_name] = correct_skater_name(score_hash[:skater_name])
          cr = find_relevant_category_result(competition.category_results.where(category: category), score_hash[:skater_name], segment, score_hash[:ranking]) || raise("no such skater: '#{skater_name}' in #{category}")
          skater = cr.skater
          score_hash[:skater_name] = skater.name
          
          score = competition.scores.create do |sc|
            sc.attributes = {
              competition_name: competition.name,
              category: category,
              segment: segment,
              skater: skater,
            }.merge(attributes)
          end
          skater.scores << score
          cr.scores << score
          segment_type = (score.segment =~ /^SHORT/) ? :short : :free
          cr.update!("#{segment_type}_ranking" => score_hash[:ranking]) if cr["#{segment_type}_ranking"].nil?
          update_score(score_hash, score)
        end
      end
      def update_score(score_hash, score)
        ## skater
        puts "    %<ranking>2d: '%{skater_name}' (%{nation}) %<tss>3.2f" % score_hash
        score_keys = [:skater_name, :ranking, :starting_number, :nation,
                      :result_pdf, :tss, :tes, :pcs, :deductions, :base_value]
        score.attributes = score_hash.slice(*score_keys)
        update_elements(score_hash, score)
        update_components(score_hash, score)
        update_sid(score_hash, score)
        score.save!
      end
      def update_container_details(score_hash, score, type, keys, summary_key)
        summary = []
        score_hash[type].each do |e|
          score.send(type).create!(e.slice(*keys))
          summary << e[summary_key]
        end
        score.update!("#{type}_summary" => summary.join('/'))
      end
      def update_elements(score_hash, score)
        update_container_details(score_hash, score, :elements, [:number, :element, :info, :base_value, :credit, :goe, :judges, :value], :element)
      end
      def update_components(score_hash, score)
        update_container_details(score_hash, score, :components, [:component, :number, :factor, :judges, :value], :value)
      end
      def update_sid(_score_hash, score)
        category_abbr = score.category || ""
        [["MEN", "M"], ["LADIES", "L"], ["PAIRS", "P"], ["ICE DANCE", "D"], ["JUNIOR ", "J"]].each do |ary|
          category_abbr = category_abbr.gsub(ary[0], ary[1])
        end

        segment_abbr =score.segment || ""
        segment_abbr = segment_abbr.split(/ /).map {|d| d[0]}.join

        score.sid = [score.competition.cid, category_abbr, segment_abbr, score.ranking].join('-')
      end
    end  ## class
  end
end
