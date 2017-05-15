require 'csv'

keys = @keys || @collection.columns.map(&:name)

csv_data = CSV.generate(headers: keys, write_headers: true) do |csv|
  @collection.each do |item|
    csv << keys.map {|h| item[h]}
  end
end
#csv_data.encode(Encoding::Shift_JIS)
