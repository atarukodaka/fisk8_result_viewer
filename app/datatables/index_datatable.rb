class IndexDatatable < AjaxDatatables::Datatable
  class Filters
    delegate :[], :each, :map, :reject, :present?, to: :@data
    attr_accessor :data, :datatable
    
    def initialize(ary = [], datatable: nil)
      @data = ary
      @datatable = datatable
    end
    def filter(*args, &block)
      Filter.new(*args, &block)
    end
    ################
    class Filter
      attr_accessor :key, :input_type, :onchange, :options, :children

      def initialize(key, input_type = :text_field, opts = {})
        @key = key
        @input_type = input_type
        @onchange = :search
        opts.slice(:field, :label, :onchange, :options, :children).each do |key, value|
          instance_variable_set "@#{key}", value
        end
        if block_given?
          @children = yield
        end
      end

      def label
        @label ||= key
      end
    end
  end
  ################
  include AjaxDatatables::Datatable::ConditionBuilder
  def manipulate(records)
    super(records).where(build_conditions(filter_search_nodes))
  end

  def filter_search_nodes
    nodes = columns.select(&:searchable).map do |column|
      sv = params[column.name].presence
      (sv) ? { column_name: column.name, search_value: sv } : nil
    end.compact

    ## season
    if (season_from = params[:season_from].presence)
      nodes << { column_name: 'season', search_value: season_from, operator: :gteq }
    end

    if (season_to = params[:season_to].presence)
      nodes << { column_name: 'season', search_value: season_to, operator: :lteq }
    end
    nodes
  end

  def default_settings
    super.merge(pageLength: 25, searching: true)
  end
end
