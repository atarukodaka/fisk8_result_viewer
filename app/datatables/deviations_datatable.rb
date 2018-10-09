class DeviationsDatatable < IndexDatatable
  def initialize(*)
    super

    columns([:score_name, :category_name, :skater_name, :skater_nation,
             :panel_name, :panel_nation, :official_number,
             :tes_deviation, :tes_deviation_ratio, :pcs_deviation, :pcs_deviation_ratio])
    columns.sources = {
      score_name:      'scores.name',
      category_name:   'categories.name',
      skater_name:     'skaters.name',
      skater_nation:   'skaters.nation',
      panel_name:      'panels.name',
      panel_nation:    'panels.nation',
      official_number: 'officials.number',
    }
    default_orders([[:tes_deviation_ratio, :desc], [:pcs_deviation_ratio, :desc]])
  end

  def fetch_records
    Deviation.all.includes([official: [:panel]], score: [:skater, :category, :competition])
      .joins([official: [:panel]], score: [:skater])
  end

  def filters
    @filters ||= [
      AjaxDatatables::Filter.new(:skater_name, :text_field),
      AjaxDatatables::Filter.new(:score_name, :text_field),
      AjaxDatatables::Filter.new(:panel_name, :text_field),
    ]
  end
end
