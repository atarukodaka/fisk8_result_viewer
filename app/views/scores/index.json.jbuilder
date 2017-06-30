json.iTotalRecords collection.object.model.count
json.iTotalDisplayRecords collection.total_count
json.data do
  json.array! collection do |score|
    json.extract! score, :name, :category, :segment, :date, :result_pdf
    json.competition_name score.competition.name
    json.season score.competition.season
    json.extract! score, :ranking, :tss, :tes, :pcs, :deductions, :base_value
    json.skater_name score.skater.name
    json.nation score.skater.nation
  end
end
