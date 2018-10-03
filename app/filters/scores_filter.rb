class ScoresFilter < IndexFilter
  def filters
    @_filters ||= [
      {
        label: hname(:skater_name),
        field: { key: :skater_name, input_type: :text_field }
      },  ## TODO: competition filters to insert
      CompetitionsFilter.new.filters,
      {
        label: hname(:category),
        fields: [:category_name, :category_type, :seniority, :team].map {|key| { key: key, input_type: :select, label: hname(key) }},
      },
      {
        label: hname(:segment),
        fields: [:segment_name, :segment_type].map {|key| { key: key, input_type: :select, label: hname(key) }},
      },
    ].flatten
  end
end  
