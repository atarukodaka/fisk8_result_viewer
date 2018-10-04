class CompetitionsFilter < IndexFilter
  def filters
    @_filters ||= [
      {
        key: :competition_name,
        label: hname(:competition_name),
        fields: [{ key: :competition_name,  input_type: :text_field, }],
      },
      {
        key: :competition_class_type,
        label: [hname(:competition_class), hname(:competition_type)].join(' / '),
        fields: [
          { key: :competition_class, input_type: :select, label: hname(:competition_class) },
          { key: :competition_type, input_type: :select, label: hname(:competition_type) },
          { key: :season_from, input_type: :select, label: hname(:season_from), onchange: :draw },
          { key: :season_to, input_type: :select, label: hname(:season_to), onchange: :draw }
        ],
      },
      {
        key: :competition_site_url,
        label: hname(:site_url),
        fields: [{ key: :site_url, input_type: :text_field }],
      }
    ]
  end
end
