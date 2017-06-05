module Fisk8ResultViewer
  module Score
    class Updater
      include Skater::FindSkater
      def update_scores(url, competition, category, segment, parser:)
        parser.parse_scores(url).each do |parsed_score|
          update_score(parsed_score, competition, category, segment)
        end
      end

      def update_score(parsed_score, competition, category, segment)
        keys = [:skater_name, :ranking, :tss, :tes, :pcs, :deductions]
        competition.scores.create!(parsed_score.slice(*keys)) do |score|
          ## category_ results
          parsed_score[:skater_name] = correct_skater_name(parsed_score[:skater_name])
          cr = find_relevant_category_result(competition.category_results.where(category: category), parsed_score[:skater_name], segment, parsed_score[:ranking]) || raise("no such skater: '#{skater_name}' in #{category}")
          cr.scores << score

          ## skater
          # TODO: correct skater name
          score.skater = cr.skater
          score.skater_name = cr.skater_name
          score.skater.scores << score

          ## attributes, identifers
          score.attributes = {category: category, segment: segment}
          score.sid = get_sid(score)

          ## segment rankings
          segment_type = (score.segment =~ /^SHORT/) ? :short : :free
          cr.update!("#{segment_type}_ranking" => parsed_score[:ranking]) if cr["#{segment_type}_ranking"].nil?

          ## elements
          score[:elements_summary] = parsed_score[:elements].map do |element|
            keys = [:number, :name, :info, :base_value, :credit, :goe, :judges, :value]
            score.elements.create!(element.slice(*keys)).name
          end
          ## components
          score[:components_summary] = parsed_score[:components].map do |component|
            keys = [:number, :name, :factor, :judges, :value]
            score.components.create!(component.slice(*keys)).value
          end

          puts "    %s-%s [%2d] %-40s (%05d) | %6.2f = %6.2f + %6.2f + %2d" % [score.category, score.segment, score.ranking, score.skater_name, score.skater.isu_number.to_i, score.tss.to_f, score.tes.to_f, score.pcs.to_f, score.deductions.to_i]
        end
      end

      private
      def find_relevant_category_result(category_results, skater_name, segment, ranking)
        ranking_type = (segment =~ /^SHORT/) ? :short_ranking : :free_ranking
        category_results.find_by(skater_name: skater_name) ||
          category_results.where(ranking_type => ranking).first
      end
      
      def get_sid(score)
        category_abbr = score.category || ""
        [["MEN", "M"], ["LADIES", "L"], ["PAIRS", "P"], ["ICE DANCE", "D"],
         ["JUNIOR ", "J"]].each do |ary|
          category_abbr = category_abbr.gsub(ary[0], ary[1])
        end

        segment_abbr =score.segment || ""
        segment_abbr = segment_abbr.split(/ /).map {|d| d[0]}.join

        [score.competition.cid, category_abbr, segment_abbr, score.ranking].join('-')
        
      end
    end ## class
  end
end
