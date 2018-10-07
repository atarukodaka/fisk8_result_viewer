module AjaxDatatables
  class Filter
    # include ActionView::Helpers::FormTagHelper
    # include ActionView::Helpers::FormOptionsHelper
    # include FormHelper

    attr_accessor :key, :input_type, :fields, :onchange, :options, :children

    def initialize(key, input_type = :text_field,  label: nil, fields: [], model: nil, onchange: :search, options: [], children: [])           ## TODO: too long args: use *args
      @key = key
      @input_type = input_type

      @fields = fields
      @label = label
      @model = model
      @onchange = onchange
      @options = options
      @children = children       ## TODO
      if block_given?
        @children = yield
      end
    end

    def label
      @label ||= @model.try(:human_attribute_name, key) || key.to_s.humanize
    end
  end
end
