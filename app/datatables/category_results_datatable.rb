class CategoryResultsDatatable < IndexDatatable
  def initialize(*)
    super
    
    columns([
              :competition_name, :competition_class, :competition_type, :category, :season,
              :ranking, :skater_name, :nation, :points,
              :short_ranking,
              :short_tss, :short_tes, :short_pcs, :short_deductions, :short_base_value,
              :free_ranking,
              :free_tss, :free_tes, :free_pcs, :free_deductions, :free_base_value,
            ])
    
    columns.sources = {
      competition_name: "competitions.name",
      competition_class: "competitions.competition_class",
      competition_type: "competitions.competition_type",
      category: "category_results.category",
      season: "competitions.season",
      skater_name: "skaters.name",
      nation: "skaters.nation",
      ranking: "category_results.ranking",
    }

    ## hidden
    [:competition_class, :competition_type].each do |key|
      columns[key].visible = false
      columns[key].orderable = false
    end
    default_orders([[:season, :desc]])
  end
  def fetch_records
    CategoryResult.includes(:competition, :skater, :scores).references(:competition, :skater).all
  end
end
