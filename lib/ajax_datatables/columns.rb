class AjaxDatatables::Columns
  extend Forwardable

  def_delegators :@data, :[], :each, :map, :find, :select
  attr_reader :datatable
  
  ################
  # initialize
  # you can initialize columns with array of:
  #  1) Hash
  #     Datatable::Columns.new([{name: "user", source: "users.user"}, {name: "address", source: "users.address"}])
  #  2) Symbol, String
  #     Datatable::Columns.new([:name, :address], datatable: UsersDatatable.new)
  #
  #      if you give datatable which has any records, each sources will be added automatically, e.g.:
  #             columns[:address].source => "users.address"
  #

  def initialize(cols = [], datatable: nil)
    @datatable = datatable
    @data = cols.map do |col|
      create_column(col)
    end
  end

  ################
  # if key given as integer, it works as array
  # if key given as symbol or string, it works as hash
  def [](key)
    case key
    when Integer
      @data[key]
    when Symbol, String
      @data.find { |c| c.name == key.to_s }
    end
  end

  def []=(key, value)
    col = create_column(value.merge('name' => key))
    @data.push(col)
  end

  def add(cols)
    [cols].flatten.map { |col| @data << create_column(col) }
  end

  ################
  # set sources of each columns
  def sources=(hash)
    hash.each do |column, source|
      self[column.to_sym].source = source
    end
  end

=begin
  def default_table_name
    @datatable.try(:records).try(:table_name)
  end
=end

  def create_column(col)
    column = AjaxDatatables::Column.new(columns: self)
    case col
    when Hash
      acceptable_keys = [:name, :source, :searchable, :orderable, :numbering]
      col.each do |key, value|
        if acceptable_keys.include?(key)
          column.send(key, value)
        else
          raise "no such key: #{key}"
        end
      end
    when Symbol, String
      column.name = col.to_s
    end
    # if source not specify, try to get table from records fetching
    #column.source ||= [default_table_name, column.name].compact.join('.')
    column
  end
end
################################################################
class AjaxDatatables::Column
  extend Property

  attr_reader :columns
  
  #properties :name, :source, default: nil
  property :name, nil
  properties :visible, :orderable, :searchable, default: true
  property :numbering, false
  property :operator, nil # set nil as default so that Searchable module can guess by field type later on

  def initialize(name: nil, columns: nil)
    @name = name.to_s
    @columns = columns
  end

  ####
  # retrive table/model info from 'sources'
  #  "users.address" => "users" as table_name, "address" as table_field, User as model
  #  "address" => "" as table_name, "address" as table_field, nil as model
  def source
    @source ||= [columns.datatable.try(:records).try(:table_name), @name].join('.')
  end
  def source=(value)
    @source = value
  end
  def table_name
    (source =~ /\./) ? source.split(/\./).first : ''
  end

  def table_field
    source.split(/\./).last
  end

  def model
    (table_name.present?) ? table_name.classify.constantize : nil
  end
end
