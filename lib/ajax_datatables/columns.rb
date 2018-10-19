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

  def initialize(cols = [], datatable:)
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

=begin
  def []=(key, value)
    col = create_column(value.merge('name' => key))
    @data.push(col)
  end
=end
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

  def create_column(col)
    case col
    when Hash
      AjaxDatatables::Column.new(col[:name], columns: self) do |column|
        col.slice(:source, :searchable, :orderable, :numbering).each do |key, value|
          column.send("#{key}=", value)
        end
      end
    when Symbol, String
      AjaxDatatables::Column.new(col.to_s, columns: self)
    end
  end
end
################
class AjaxDatatables::Column
  extend Property

  attr_reader :columns
  attr_writer :source
  attr_accessor :name, :visible, :orderable, :searchable, :numbering, :operator

  def initialize(name, columns:)
    @name = name.to_s
    @columns = columns
    @visible = @orderable = @searchable = true
    @numbering = @operator = nil
    yield(self) if block_given?
  end

  ####
  # retrive table/model info from 'sources'
  #  "users.address" => "users" as table_name, "address" as table_field, User as model
  #  "address" => "" as table_name, "address" as table_field, nil as model
  def source
    @source ||= self.source = [columns.datatable.default_table, name].join('.')
  end

  def table_name
    source.split(/\./).first
  end

  def table_field
    source.split(/\./).last
  end

  def table_model
    table_name.classify.constantize
  end
end
