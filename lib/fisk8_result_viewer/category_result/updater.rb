module Fisk8ResultViewer
  module CategoryResult
    class Updater
      def update_category_result(result, competition, category)
        keys = [:category, :ranking, :points, :short_ranking, :free_ranking]
        competition.category_results.create!(result.slice(*keys)) do |cr|
          cr.skater = ::Skater.find_or_create_by_isu_number_or_name(result[:isu_number], result[:skater_name]) do |sk|
            sk.category = category.seniorize
            sk.nation = result[:nation]
          end
          cr.skater.category_results << cr
          cr.category = category
          puts cr.to_s
        end
      end
    end
  end
end
