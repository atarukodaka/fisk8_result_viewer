## locals: collection, display_keys(optional)

require 'csv'

display_keys ||= collection.columns.map(&:name)

csv_data = CSV.generate(headers: display_keys, write_headers: true) do |csv|
  collection.each do |item|
    csv << display_keys.map {|h| item[h]}
  end
end
#csv_data.encode(Encoding::Shift_JIS)
