class ScoresDatatable < IndexDatatable
  class Filters < IndexDatatable::Filters
    def initialize
      model = Score
      super([
        CompetitionsDatatable::Filters.new.reject { |filter| filter.key == :site_url },
        Filter.new(:skater_name, :text_field, model: model),
        Filter.new(:category, nil, model: model) {
          [
            Filter.new(:category_name, :select, model: model),
            Filter.new(:category_type_name, :select, model: model),
            Filter.new(:seniority, :select, model: model),
            Filter.new(:team, :select, model: model),
          ]
        },
        Filter.new(:segment, nil, model: model) {
          [
            Filter.new(:segment_name, :select, model: model),
            Filter.new(:segment_type, :select, model: model),
          ]
        },
      ].flatten)
    end
  end
  # ###############"
  def initialize(*)
    super

    columns([:name, :competition_name, :competition_class, :competition_type,
             :category_name, :category_type_name, :team, :seniority, :segment_name, :segment_type,
             :season, :date, :result_pdf, :ranking, :skater_name, :nation,
             :tss, :tes, :pcs, :deductions, :base_value])

    columns.sources = {
      name:              'scores.name',
      competition_name:  'competitions.name',
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
    columns[:date].searchable = false
    # columns[:category_type].operator = :eq
    columns[:team].operator = :boolean

    default_orders([[:date, :desc]])
  end

  def fetch_records
    tables = [:competition, :skater, :category, :segment, category: [:category_type]]
    super.includes(tables).joins(tables)
  end
end
