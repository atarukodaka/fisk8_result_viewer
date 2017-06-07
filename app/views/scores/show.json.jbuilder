json.extract! score, :sid, :competition_name, :category, :segment, :date, :result_pdf
json.season score.competition.season
json.extract! score, :ranking, :skater_name, :nation, :tss, :tes, :pcs, :deductions, :base_value

json.elements do
  json.array! score.elements do |element|
    json.extract! element, :number, :name, :info, :base_value, :credit, :goe, :judges, :value
  end
end

json.components do
  json.array! score.components do |component|
    json.extract! component, :number, :name, :factor, :judges, :value
  end
end
