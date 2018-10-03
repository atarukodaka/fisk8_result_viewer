class SkatersFilter < IndexFilter
  def filters
    @_filters ||= [
      {
        label: hname(:name),
        field: { key: :name, input_type: :text_field, },
      },
      {
        label: hname(:category_type),
        fields: [{ key: :category_type, input_type: :select, }],
      },
      {
        label: hname(:nation),
        field: { key: :nation, input_type: :select, },
      },
    ]
  end
end
