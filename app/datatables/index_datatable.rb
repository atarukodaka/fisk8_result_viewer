class IndexDatatable < AjaxDatatables::Datatable
  class Filters
    delegate :[], :each, :map, :reject, :flatten, :present?, to: :@data
    attr_accessor :data, :datatable

    def initialize(ary = [], datatable: nil)
      @data = ary
      @datatable = datatable
    end

    def filter(key, input_type, opts = {}, &block)
      opts[:filters] = self
      Filter.new(key, input_type, opts, &block)
    end
    ################
    class Filter
      attr_accessor :key, :input_type, :onchange, :options, :children, :checked, :filters

      def initialize(key, input_type = :text_field, opts = {})
        @key = key
        @input_type = input_type
        @onchange = :search
        opts.slice(:field, :label, :onchange, :options, :children, :checked, :filters).each do |key, value|
          instance_variable_set "@#{key}", value
        end
        if block_given?
          @children = yield
        end
      end

      def label
        @label ||= key
      end

      def render(vc)
        datatable = filters.datatable
        #vc = datatable.view_context
        onc = (onchange == :draw) ? vc.ajax_draw(datatable) : vc.ajax_search(key, datatable)

        case input_type
        when :text_field
          vc.text_field_tag(key, vc.params[key], size: 70, onchange: onc)
        when :select
          if options.present?
            vc.select_tag(key, vc.options_for_select(options, vc.params[key]), onchange: onc)
          else
            vc.select_tag_with_options(key, onchange: onc)
          end
        when :checkbox
          vc.check_box_tag(key, 'on', vc.params[:having_scores] == 'on', onchange: onc)  ## TODO: having_score
        end
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
