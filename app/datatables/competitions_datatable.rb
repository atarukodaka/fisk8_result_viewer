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
            #filter(:season_from, :select, onchange: lambda { |dt| ajax_draw(dt) }),
            #filter(:season_to, :select, onchange: lambda { |dt| ajax_draw(dt) }),
            # filter(:season_to, :select, onchange: ajax_search(:season, datatable)),
            filter(:season_operator, :select, label: '', onchange: lambda { |dt| ajax_draw(dt) },
                       options: { '=': :eq, '<': :lt, '<=': :lteq, '>': :gt, '>=': :gteq }, label: "season"),
            filter(:season, :select, label: "")
          ]
        },
        filter(:site_url, :text_field),
      ]
    end
  end
  ################
  #include IndexDatatable::SeasonFilterable
  def initialize(*)
    super
    columns([:name, :short_name, :site_url, :city, :country,
             :competition_class, :competition_type, :season, :start_date, :timezone])
    default_orders([[:start_date, :desc]])
    #columns[:season].operator = lambda {|arel|  binding.pry; arel.eq('2016-17')}
    columns[:season].operator = params[:season_operator].presence || :eq
  end
end
