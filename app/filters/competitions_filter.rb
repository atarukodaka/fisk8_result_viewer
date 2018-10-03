class CompetitionsFilter < IndexFilter
  def filters
    @_filters ||= [
      {
        label: hname(:competition_name),
        fields: [{ key: :competition_name,  input_type: :text_field, }],
      },
      {
        label: [hname(:competition_class), hname(:competition_type)].join(' / '),
        fields: [
          { key: :competition_class, input_type: :select, label: hname(:competition_class) },
          { key: :competition_type, input_type: :select, label: hname(:competition_type) },
          { key: :season_from, input_type: :select, label: hname(:season_from), onchange: :draw },
          { key: :season_to, input_type: :select, label: hname(:season_to), onchange: :draw }],
      },
      {
        label: Competition.human_attribute_name(:site_url),
        fields: [{ key: :site_url, input_type: :text_field }],
      }
    ]
  end
end
