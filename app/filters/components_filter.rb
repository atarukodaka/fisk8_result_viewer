class ComponentsFilter < IndexFilter
  def filters
    names = {
      "" => nil,
      "Skating Skills" => 1,
      "Transitions" => 2,
      "Performace" => 3,
      "Composition" => 4,
      "Interpreation" => 5,
    }
    @filters ||= [
      {
        label: hname("name"),
        fields: [ { key: :number, input_type: :select, options: names}],
      },
      {
        label: hname("value"),
        fields: [
          { key: :value_operator, input_type: :select, options: {'=': :eq, '<': :lt, '<=': :lteq, '>': :gt, '>=': :gteq},onchange: :draw},
          { key: :value, input_type: :text_field}
        ],
      },
      ScoresFilter.new.filters      
    ].flatten
    
  end
end
