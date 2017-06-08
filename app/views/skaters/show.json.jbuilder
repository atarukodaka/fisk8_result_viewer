json.name skater.name
json.nation skater.nation
json.isu_number skater.isu_number
json.category skater.category

json.result_summary do
  json.higest_score skater.category_results.highest_score
  json.competitions_participated skater.category_results.count
  json.gold_won skater.category_results.where(ranking: 1).count
  json.highest_ranking skater.category_results.highest_ranking
end

json.competition_results do
  json.array! competition_results do |cr|
    json.competition_name cr.competition.name
    json.date cr.competition.start_date
    json.ranking cr.ranking
    json.points cr.points
    json.short_ranking cr.short_ranking
    json.free_ranking cr.free_ranking
  end
end
