class ComponentsDecorator < EntriesDecorator
  def column_names
    [:sid, :competition_name, :date, :season, :ranking, :skater_name, :nation,
     :number, :name, :factor, :judges, :value]
  end
end

class ComponentDecorator < ElementDecorator # EntryDecorator
end