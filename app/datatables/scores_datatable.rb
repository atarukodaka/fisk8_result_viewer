class ScoresDatatable < IndexDatatable
  class Filters < IndexDatatable::Filters
    def initialize(*)
      super

      @data = [
        # CompetitionsDatatable::Filters.new.data.reject { |filter| filter.key == :site_url },
        CompetitionsDatatable::Filters.new(datatable: datatable).reject { |filter| filter.key == :site_url },
        filter(:score_name, :text_field),
        filter(:skater_name, :text_field),
        filter(:category, nil) {
          [
            filter(:category_name, :select),
            filter(:category_type_name, :select),
            filter(:seniority, :select),
            filter(:team, :select),
          ]
        },
        filter(:segment, nil) {
          [
            filter(:segment_name, :select),
            filter(:segment_type, :select),
          ]
        },
      ].flatten
    end
  end
  # ###############"
  def initialize(*)
    super
    columns([:score_name, :competition_name, :competition_short_name,
             :competition_class, :competition_type,
             :category_name, :category_type_name, :team, :seniority, :segment_name, :segment_type,
             :season, :date, :result_pdf, :ranking, :skater_name, :nation,
             :tss, :tes, :pcs, :deductions, :base_value])

    columns.sources = {
      score_name:              'scores.name',
      competition_name:  'competitions.name',
      competition_short_name:  'competitions.short_name',
      competition_class: 'competitions.competition_class',
      competition_type:  'competitions.competition_type',
      category_name:     'categories.name',
      category_type_name:     'category_type.name',
      team:              'categories.team',
      seniority:         'categories.seniority',
      segment_name:      'segments.name',
      segment_type:      'segments.segment_type',
      season:            'competitions.season',
      skater_name:       'skaters.name',
      nation:            'skaters.nation',
    }

    [:competition_type, :competition_class, :competition_name, :season, :category_type_name, :seniority,
     :segment_type, :team].each do |key|
      columns[key].visible = false
      columns[key].orderable = false
    end

    columns[:ranking].operator = :eq
    #columns[:date].searchable = false
    columns[:team].operator = :boolean
    columns[:season].operator = params[:season_operator].presence || :eq if view_context

    default_orders([[:date, :desc]])
  end

  def fetch_records
    tables = [:competition, :skater, :category, :segment, category: [:category_type]]
    super.includes(tables).joins(tables)
  end
end
