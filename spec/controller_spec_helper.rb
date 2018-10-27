module ControllerSpecHelper
  using MapValue

  ################
  ## filter
=begin
  shared_context :json_filter do |key, datatable|
    it {
      item = datatable.data.first
      value = item.send(key)
      get :index, params: { format: :json, key => value }
      result = JSON.parse(response.body)
      expect(result.any? {|d| d[key.to_s] == value}).to be true
    }
  end
=end  
  ################
  ## sort
=begin
  shared_context :sort_column do |key, direction = :asc, datatable:|
    it {
      column = datatable.columns[key]

      get :index, params: { format: :json, sort_column: key, sort_direction: direction }
      got = JSON.parse(response.body).map_value(key.to_s).map(&:to_s)

      expected = datatable.data.order("#{column.source} #{direction}").map { |d| d.send(key).to_s }
      expect(got).to eq(expected)
    }
  end
=end
  shared_context :sort do |datatable|
    datatable.columns.select(&:orderable).map(&:name).map(&:to_sym).each do |key|
      it {
        column = datatable.columns[key]

        ## asc
        direction = :asc
        get :index, params: { format: :json, sort_column: key, sort_direction: direction }
        got = JSON.parse(response.body).map_value(key.to_s).map(&:to_s)

        expected = datatable.data.order("#{column.source} #{direction}").map { |d| d.send(key).to_s }
        expect(got).to eq(expected)

        ## desc
        direction = :desc
        get :index, params: { format: :json, sort_column: key, sort_direction: direction }
        got = JSON.parse(response.body).map_value(key.to_s).map(&:to_s)

        expected = datatable.data.order("#{column.source} #{direction}").map { |d| d.send(key).to_s }
        expect(got).to eq(expected)
      }
      #include_context :sort_column, key, :asc, datatable: datatable
      #include_context :sort_column, key, :desc, datatable: datatable
    end
  end

  ################
  ## json
  shared_context :json do |datatable|
    context 'length' do
      subject(:response) { get :index, params: { format: :json, length: 1 } }
      it { expect(JSON.parse(response.body).count).to eq(1) }
    end

    context 'offset' do
      subject(:response) { get :index, params: { format: :json, offset: datatable.data.count - 1 } }
      it { expect(JSON.parse(response.body).count).to eq(1) }
    end

    context 'sort' do
      include_context :sort, datatable
    end
  end


end
