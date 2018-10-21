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
      opts[:onchange] ||= lambda { |dt| ajax_search(key, dt) }
      Filter.new(key, input_type, opts, &block)
    end
  end
  ################
  class Filter
    attr_accessor :key, :input_type, :onchange, :options, :children, :checked

    def initialize(key, input_type, opts = {})
      @key = key
      @input_type = input_type
      @children = []
      opts.slice(:field, :label, :onchange, :options, :children, :checked).each do |k, v|
        instance_variable_set "@#{k}", v
      end
      if block_given?
        @children = yield
      end
    end

    def label
      @label ||= key
    end

=begin
    def render(view, datatable:)
      onc = onchange.call(datatable)
      case input_type
      when :text_field
        view.text_field_tag(key, view.params[key], size: 70, onchange: onc)
      when :select
        if options.present?
          view.select_tag(key, view.options_for_select(options, view.params[key]), onchange: onc)
        else
          view.select_tag_with_options(key, onchange: onc)
        end
      when :checkbox
        view.check_box_tag(key, 'on', checked, onchange: onc)
      end
    end
=end
  end
end
