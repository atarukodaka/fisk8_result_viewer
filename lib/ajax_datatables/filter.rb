module AjaxDatatables
  class Filter
    attr_accessor :key, :input_type, :value_function, :onchange, :options, :children

    def initialize(key, input_type = :text_field, *args)
      @key = key
      @input_type = input_type

      if args.first.present?
        [:value_function, :field, :label, :model, :onchange, :options, :children].each do |var|
          instance_variable_set "@#{var}", args.first[var]
        end
      end
=begin
      @fields = fields
      @label = label
      @model = model
      @onchange = onchange
      @options = options
      @children = children       ## TODO
=end
      if block_given?
        @children = yield
      end
    end

    def label
      @label ||= @model.try(:human_attribute_name, key) || key.to_s.humanize
    end
  end
end
