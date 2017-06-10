module Fisk8ResultViewer
  module CategoryResult
    class Updater
      include Skater::FindSkater
      ###
      def update_category_results(url, competition, category, parser:)
        #parser = Fisk8ResultViewer::CategoryResult::Parser.new
        #parser = Parsers.get_parser(:category_result, 
        
        parser.parse_category_results(url, category).each do |result|
          keys = [:category, :ranking, :points, :short_ranking, :free_ranking]
          competition.category_results.create!(result.slice(*keys)) do |cr|
            #cr.competition_name = competition.name
            cr.category = category
            result[:skater_name] = correct_skater_name(result[:skater_name])
            cr.skater = find_or_create_skater(result[:isu_number], result[:skater_name]) do |sk|
              sk.category = category.gsub(/^JUNIOR /, '')
              sk.nation = result[:nation]
            end
            cr.skater.category = category
            cr.skater.category_results << cr
            puts "  %s %2d %-40s (%6d)[%s] | %6.2f %2d / %2d" %
              [cr.category, cr.ranking, cr.skater.name, cr.skater.isu_number.to_i, cr.skater.nation, cr.points.to_f, cr.short_ranking.to_i, cr.free_ranking.to_i]
          end
        end
      end
    end
  end
end
