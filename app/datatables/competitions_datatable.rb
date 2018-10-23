class CompetitionsDatatable < IndexDatatable
  class Filters < IndexDatatable::Filters
    def initialize(*)
      super
      @data = [
        filter(:competition_name, nil){
          [
            filter(:competition_name, :text_field, size: 40),
            filter(:competition_short_name, :select)
          ]
        },
        filter(:competition_class, nil) {
          [
            filter(:competition_class, :select),
            filter(:competition_type, :select),
            filter(:season_operator, :select, label: 'season', onchange: lambda { |dt| ajax_draw(dt) },
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
    columns([:competition_name, :competition_short_name, :site_url, :city, :country,
             :competition_class, :competition_type, :season, :start_date, :timezone])
    columns[:competition_name].source = "competitions.name"
    columns[:competition_short_name].source = "competitions.short_name"
      
    default_orders([[:start_date, :desc]])
    # columns[:season].operator = lambda {|arel|  binding.pry; arel.eq('2016-17')}
    columns[:season].operator = params[:season_operator].presence || :eq if view_context
  end
end
