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
            filter(:season_from, :select, onchange: lambda {|dt| ajax_draw(dt)}),
            filter(:season_to, :select, onchange: lambda {|dt| ajax_draw(dt) }),
            #filter(:season_to, :select, onchange: ajax_search(:season, datatable)),
          ]
        },
        filter(:site_url, :text_field),
      ]
    end
  end
  ################
  include IndexDatatable::SeasonFilterable
  def initialize(*)
    super
    columns([:name, :short_name, :site_url, :city, :country,
             :competition_class, :competition_type, :season, :start_date, :timezone])
    default_orders([[:start_date, :desc]])
  end
end
