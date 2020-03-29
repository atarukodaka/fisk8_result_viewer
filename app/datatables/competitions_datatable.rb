class CompetitionsDatatable < IndexDatatable
  class Filters < IndexDatatable::Filters
    def initialize(ary = [], datatable: nil)
      super(ary, datatable: datatable)
      @data = [
        filter(:competition_name, nil) {
          [
            filter(:competition_name, :text_field, size: 40),
            filter(:competition_key, :select)
          ]
        },
        filter(:competition_class, nil) {
          [
            filter(:competition_class, :select),
            filter(:competition_subclass, :select),
            filter(:season_operator, :select, label: 'season', onchange: ->(dt) { ajax_draw(dt) },
                   options: { '=': :eq, '<': :lt, '<=': :lteq, '>': :gt, '>=': :gteq }),
            filter(:season, :select, label: ''),
          ]
        },
        filter(:site_url, :text_field),
      ]
    end
  end

  ################
  # include IndexDatatable::SeasonFilterable
  def initialize(*)
    super
    columns([:competition_name, :competition_key, :site_url, :city, :country,
             :competition_class, :competition_subclass, :season, :start_date, :timezone])
    columns.sources = source_mappings

    [:competition_key, :competition_class, :competition_subclass].each do |key|
      columns[key].operator = :eq
    end

    default_orders([[:start_date, :desc]])
    columns[:season].operator = params[:season_operator].presence || :eq if view_context
  end
end
