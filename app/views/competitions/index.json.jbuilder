json.iTotalRecords collection.object.model.count
json.iTotalDisplayRecords collection.total_count
json.data do
  json.array! collection do |item|
    json.extract! item, :short_name, :name, :season, :site_url, :competition_type, :city, :country, :start_date, :end_date
  end
end
