module Fisk8ResultViewer
  module CategoryResult
    class Updater
      def update_category_results(url, competition, category, parser:)
        parser.parse_category_results(url, category).each do |result|
          keys = [:category, :ranking, :points, :short_ranking, :free_ranking]
          competition.category_results.create!(result.slice(*keys)) do |cr|
            cr.skater = ::Skater.find_or_create_by_isu_number_or_name(result[:isu_number], result[:skater_name]) do |sk|
              sk.category = category.seniorize
              sk.nation = result[:nation]
            end
            cr.skater.category_results << cr
            cr.category = category
            
            puts "  %s %2d %-40s (%6d)[%s] | %6.2f %2d / %2d" %
              [cr.category, cr.ranking, cr.skater.name, cr.skater.isu_number.to_i, cr.skater.nation, cr.points.to_f, cr.short_ranking.to_i, cr.free_ranking.to_i]
          end
        end
      end
    end
  end
end
