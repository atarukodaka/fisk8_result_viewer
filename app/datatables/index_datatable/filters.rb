class IndexDatatable
  class Filters
    include FormHelper  ## for ajax_draw(), ajax_search()
    delegate :[], :each, :map, :reject, :flatten, :present?, to: :@data
    attr_accessor :data, :datatable

    def initialize(ary = [], datatable: nil)
      @data = ary
      @datatable = datatable
    end

    def filter(key, input_type, opts = {}, &block)
      opts[:onchange] ||= lambda {|dt| ajax_search(key, dt) }
      Filter.new(key, input_type, opts, &block)
    end
    ################
    class Filter
      attr_accessor :key, :input_type, :onchange, :options, :children, :checked

      def initialize(key, input_type, opts = {})
        @key = key
        @input_type = input_type

        opts.slice(:field, :label, :onchange, :options, :children, :checked).each do |key, value|
          instance_variable_set "@#{key}", value
        end
        if block_given?
          @children = yield
        end
      end

      def label
        @label ||= key
      end

      def render(vc, datatable:)
        #onc = (onchange == :draw) ? vc.ajax_draw(datatable) : vc.ajax_search(key, datatable)
        #onc = onchange || vc.ajax_search(key, datatable)
        #onc = onchange&.call(datatable) || vc.ajax_search(key, datatable)
        onc = onchange.call(datatable)
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
          vc.check_box_tag(key, 'on', checked, onchange: onc)
        end
      end
    end
  end
end
