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
      AjaxDatatables::Filter.new(:competition_name, :text_field, model: model),
      AjaxDatatables::Filter.new(:competition_class_type) {
        [
          AjaxDatatables::Filter.new(:competition_class, :select, model: model),
          AjaxDatatables::Filter.new(:competition_type, :select, model: model),
          AjaxDatatables::Filter.new(:season_from, :select, model: model, onchange: :draw),
          AjaxDatatables::Filter.new(:season_to, :select, model: model, onchange: :draw),
        ]
      },
      AjaxDatatables::Filter.new(:site_url, :text_field, model: model)
    ]
  end

  def fetch_records
    Competition.all
  end
end
