module AjaxDatatables
  class Filters
    include FormHelper  ## for ajax_draw(), ajax_search()
    delegate :[], :each, :map, :select, :reject, :flatten, :present?, :to_a, :first, :last, :find, to: :@data
    attr_accessor :datatable

    def initialize(ary = [], datatable: nil)
      @data = ary
      @datatable = datatable
    end

    def filter(key, input_type, opts = {}, &block)
      # opts[:onchange] ||= lambda { |dt| ajax_search(key, dt) }
      opts[:filters] = self
      Filter.new(key, input_type, opts, &block)
    end

    def flatten
      map {|filter| filter.children.presence || filter}.flatten
    end
  end
  ################
  class Filter
    attr_accessor :key, :input_type, :onchange, :options, :children, :checked, :size, :filters

    def initialize(key, input_type, opts = {})
      @key = key
      @input_type = input_type
      @children = []
      opts.slice(:field, :label, :onchange, :options, :children, :checked, :size, :filters).each do |k, v|
        instance_variable_set "@#{k}", v
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
