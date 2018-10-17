class CompetitionsDatatable < IndexDatatable
  include AjaxDatatables
  def initialize(*)
    super
    columns([:name, :short_name, :site_url, :city, :country,
             :competition_class, :competition_type, :season, :start_date])
    default_orders([[:start_date, :desc]])
  end

  def filters
    model = Competition
    @filters ||= [
      Filter.new(:competition_name, :text_field, model: model),
      Filter.new(:competition_class_type) {
        [
          Filter.new(:competition_class, :select, model: model),
          Filter.new(:competition_type, :select, model: model),
          Filter.new(:season_from, :select, model: model, onchange: :draw),
          Filter.new(:season_to, :select, model: model, onchange: :draw),
        ]
      },
      Filter.new(:site_url, :text_field, model: model)
    ]
  end

  def fetch_records
    Competition.all
  end
end
