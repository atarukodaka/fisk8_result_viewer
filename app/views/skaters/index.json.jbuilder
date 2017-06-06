json.array! collection do |item|
  json.extract! item, :name, :nation, :isu_number, :category
end
