module ScoreVirtualAttributes
  ## shared virtual attributes for elements/components
  [:score_name, :competition_name, :competition_short_name, :competition_class,
   :competition_type, :team, :season,
   :category_name, :category_type_name, :seniority, :segment_name, :segment_type,
   :ranking, :skater_name, :nation, :date].each do |key|
    delegate key, to: :score
  end
end
