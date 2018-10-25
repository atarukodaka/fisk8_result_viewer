class ScoreDetailsDatatable < IndexDatatable
  def initialize(*)
    super
    columns([:score_name, :competition_name, :competition_class, :competition_type,
             :category_name, :category_type_name, :team, :seniority, :segment_name, :segment_type,
             :date, :season, :skater_name, :nation,])
    columns.sources = source_mappings.slice(*column_names.map(&:to_sym))

    ## searchable
    columns[:date].searchable = false

    ## visible
    [:competition_class, :competition_type, :category_type_name, :seniority, :team, :segment_type].each { |key|
      columns[key].visible = false
      columns[key].orderable = false
    }
    ## operatoer
    columns[:category_name].operator = :eq
    columns[:team].operator = :boolean

    default_orders([[:value, :desc]])
  end
end
