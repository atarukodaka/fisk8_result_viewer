class SkatersFilter < IndexFilter
  def filters
    @_filters ||= [
      {
        key: :name,
        label: hname(:name),
        fields: [{ key: :name, input_type: :text_field, }],
      },
      {
        key: :category_type,
        label: hname(:category_type),
        fields: [{ key: :category_type, input_type: :select, }],
      },
      {
        key: :nation,
        label: hname(:nation),
        fields: [{ key: :nation, input_type: :select, }],
      },
      {
        key: :having_scores,
        label: hname(:having_scores),
        #fields: [{ key: :having_scores, input_type: :select, options: ['on', 'off'], onchange: :draw} ],
        fields: [{ key: :having_scores, input_type: :checkbox, onchange: :draw} ],
      },
    ]
  end
end
