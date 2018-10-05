class ElementsFilter < IndexFilter
  include ActionView::Helpers::OutputSafetyHelper   ## for raw()
  def filters
    ## rubocop:disable Rails/OutputSafety
    @filters ||= [
      { label: hname(:element_name),
        fields: [{ key: :name_operator, input_type: :select,
                   options: { '=': :eq, raw('&sube;') => :matches }, onchange: :draw },
                 { key: :element_name, input_type: :text_field }], },
      {
        label: hname(:element_type),
        fields: [{ key: :element_type, input_type: :select, label: hname(:element_type) },
                 { key: :element_subtype, input_type: :select, label: hname(:element_subtype) }]
      },
      {
        label: hname(:goe),
        fields: [{ key: :goe_operator, input_type: :select,
                   options: { '=': :eq, '<': :lt, '<=': :lteq, '>': :gt, '>=': :gteq }, onchange: :draw },
                 { key: :goe, input_type: :text_field }]
      },
      ScoresFilter.new.filters
    ].flatten
    # rubocop:enable Rails/OutputSafety
  end
end
