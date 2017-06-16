json.array! collection do |item|
  json.extract! item.score, :name, :competition_name, :date, :ranking, :skater_name, :nation
  json.season item.score.competition.season
  json.extract! item, :number, :name, :factor, :judegs, :value
end
