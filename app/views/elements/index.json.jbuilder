json.array! collection do |item|
  json.extract! item.score, :sid, :competition_name, :date, :ranking, :skater_name, :nation
  json.season item.score.competition.season
  json.extract! item, :number, :name, :credit, :info, :base_value, :goe, :judges, :value
end
