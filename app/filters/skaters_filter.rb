=begin
class Filter
  include ActionView::Helpers::FormTagHelper

  attr_reader :fields

  def initialize(label: "", fields: [], field: nil)
    @fields = [field, fields].flatten.compact
  end
end

class Field
  def initialize(label: "", key: , input_type: , onchange: :search)
  end
end
=end
class SkatersFilter < IndexFilter
  def filters
    @_filters ||= [
      {
        label: hname(:name),
        fields: [{ key: :name, input_type: :text_field, }],
      },
      {
        label: hname(:category_type),
        fields: [{ key: :category_type, input_type: :select, }],
      },
      {
        label: hname(:nation),
        fields: [{ key: :nation, input_type: :select, }],
      }
    ]
  end
end
