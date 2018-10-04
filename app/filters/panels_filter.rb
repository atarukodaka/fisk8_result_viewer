class PanelsFilter < IndexFilter
  def filters
    @filters ||= [
      {
        key: :name,
        label: hname(:name),
        fields: [ { key: :name, input_type: :text_field} ],
      },
      {
        key: :nation,
        label: hname(:nation),
        fields: [ { key: :nation, input_type: :text_field} ],
      },
      
    ]
  end
end
