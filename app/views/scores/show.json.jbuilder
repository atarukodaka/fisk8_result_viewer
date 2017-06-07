json.extract! score, :sid
json.competition_name score.competition.name
json.extract! score, :category, :segment, :date, :result_pdf
json.season score.competition.season
json.extract! score, :ranking
json.skater_name score.skater.name
json.nation score.skater.nation
json.extract! score, :tss, :tes, :pcs, :deductions, :base_value

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
