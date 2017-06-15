module Fisk8ResultViewer
  module Score
    class Updater
=begin
      def update_scores(url, competition, category, segment, parser:, attributes: {})
        parser.parse_scores(url).each do |parsed_score|
          update_score(parsed_score, competition, category, segment, attributes: attributes)
        end
      end
=end
      def update_score(parsed_score, competition, category, segment, attributes: {})
        keys = [:ranking, :starting_number, :tss, :tes, :pcs, :deductions, :deduction_reasons, :result_pdf, :base_value]
        competition.scores.create!(parsed_score.slice(*keys)) do |score|
          ## category_ results
          parsed_score[:skater_name] = ::Skater.correct_name(parsed_score[:skater_name])
          cr = find_relevant_category_result(competition.category_results.where(category: category), parsed_score[:skater_name], segment, parsed_score[:ranking]) ||
            raise("no such skater: '#{parsed_score[:skater_name]}' in #{category}")
          cr.scores << score

          ## skater
          score.skater = cr.skater
          score.skater.scores << score

          ## attributes, identifers
          score.attributes = attributes.merge({category: category, segment: segment})
          score.sid = get_sid(score)
          score.save!   ## need to save here for elements/components creation

          ## segment rankings
          segment_type = (score.segment =~ /^SHORT/) ? :short : :free
          cr.update!("#{segment_type}_ranking" => parsed_score[:ranking]) if cr["#{segment_type}_ranking"].nil?

          ## elements
          parsed_score[:elements].map do |element|
            keys = [:number, :name, :info, :base_value, :credit, :goe, :judges, :value]
            score.elements.create!(element.slice(*keys)).name
          end
          ## components
          parsed_score[:components].map do |component|
            keys = [:number, :name, :factor, :judges, :value]
            score.components.create!(component.slice(*keys)).value
          end

          puts score.to_s
        end
      end

      private
      def find_relevant_category_result(category_results, skater_name, segment, ranking)
        ranking_type = (segment =~ /^SHORT/) ? :short_ranking : :free_ranking
        category_results.joins(:skater).where("skaters.name" => skater_name).first ||
          category_results.where(ranking_type => ranking).first
      end
      
      def get_sid(score)
        category_abbr = score.category || ""
        [["MEN", "M"], ["LADIES", "L"], ["PAIRS", "P"], ["ICE DANCE", "D"],
         ["JUNIOR ", "J"]].each do |ary|
          key, abbr = ary
          category_abbr = category_abbr.gsub(key, abbr)
        end

        segment_abbr = score.segment.to_s.split(/ +/).map {|d| d[0]}.join # e.g. 'SHORT PROGRAM' => 'SP'

        [score.competition.cid, category_abbr, segment_abbr, score.ranking].join('-')
        
      end
    end ## class
  end
end
