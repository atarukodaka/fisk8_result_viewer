json.array! collection do |item|
  json.extract! item, :cid, :name, :season, :city, :country, :start_date, :end_date
end
