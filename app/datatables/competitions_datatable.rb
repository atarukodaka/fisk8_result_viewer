class CompetitionsDatatable < IndexDatatable
  class Filters < IndexDatatable::Filters
    def initialize(*)
      super
      @data = [
        filter(:competition_name, :text_field),
        filter(:competition_class, nil) {
          [
            filter(:competition_class, :select),
            filter(:competition_type, :select),
            filter(:season_from, :select, onchange: :draw),
            filter(:season_to, :select, onchange: :draw),
          ]
        },
        filter(:site_url, :text_field),
      ]
=begin
      model = Competition
      @data = [
        Filter.new(:competition_name, :text_field, model: model),
        Filter.new(:competition_class, nil, model: model) {
          [
            Filter.new(:competition_class, :select, model: model),
            Filter.new(:competition_type, :select, model: model),
            Filter.new(:season_from, :select, model: model, onchange: :draw),
            Filter.new(:season_to, :select, model: model, onchange: :draw),
          ]
        },
        Filter.new(:site_url, :text_field, model: model)
      ]
=end
    end
  end
  ################
  def initialize(*)
    super
    columns([:name, :short_name, :site_url, :city, :country,
             :competition_class, :competition_type, :season, :start_date, :timezone])
    default_orders([[:start_date, :desc]])
  end
end
