module ControllerSpecHelper
  using MapValue

  shared_context :contains_all do |datatable|
    context 'contains_all' do
      it {
        get :index
        datatable.data.all.each do |item|
          expect(response.body).to have_content(item.name)
        end
      }
    end
  end

  shared_context :sort do |datatable, format: :json|
    def parse_csv(text, key: )
      csv = CSV.parse(response.body, headers: true)
      index = csv.headers.index(key.to_s)
      csv.map {|d| d[index]}
    end
    shared_examples :sort_key do |key, direction=:asc|
      it {
        column = datatable.columns[key]

        get :index, params: { format: format, sort_column: key, sort_direction: direction }

        got =
          case format
          when :json
            JSON.parse(response.body).map_value(key.to_s).map(&:to_s)
          when :csv
            parse_csv(response.body, key: key)
          end
        expected = datatable.data.order("#{column.source} #{direction}").map { |d| d.send(key).to_s }
        expect(got).to eq(expected)
      }
    end
    ################
    datatable.columns.select(&:orderable).map(&:name).map(&:to_sym).each do |key|
      it_behaves_like :sort_key, key, :asc
      it_behaves_like :sort_key, key, :desc
    end
  end

  ################
  ## json
  shared_context :format_response do |datatable, format: :json|
    shared_examples :count_to_be do |n|
      it {
        count = 
          case format
          when :json
            JSON.parse(response.body).count
          when :csv
            response.body.split(/\n/)[1..-1].count
          end
        expect(count).to eq(n)
      }
    end
    context 'length' do
      subject(:response) { get :index, params: { format: format, length: 1 } }
      it_behaves_like :count_to_be, 1
    end

    context 'offset' do
      subject(:response) { get :index, params: { format: format, offset: datatable.data.count - 1 } }
      it_behaves_like :count_to_be, 1
    end

    context 'sort' do
      include_context :sort, datatable, format: format
    end
  end
end
################
RSpec.configure do |config|
  config.include ControllerSpecHelper
end
