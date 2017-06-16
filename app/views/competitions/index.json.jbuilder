json.array! collection do |item|
  json.extract! item, :short_name, :name, :season, :city, :country, :start_date, :end_date
end
