json.array! collection do |score|
  json.extract! score, :sid, :competition_name, :category, :segment, :date, :result_pdf
  json.season score.competition.season
  json.extract! score, :ranking, :skater_name, :nation, :tss, :tes, :pcs, :deductions, :base_value
end

