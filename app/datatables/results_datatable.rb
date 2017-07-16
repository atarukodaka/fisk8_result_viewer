class ResultsDatatable < IndexDatatable
  def initialize
    data = Result.includes(:competition, :skater).references(:competition, :skater).all
    cols = [:competition_name, :competition_class, :competition_type, :category, :season, :ranking, :skater_name, :nation, :points,
            :short_ranking, :short_tss, :short_tes, :short_pcs, :short_deductions, :short_bv,
            :free_ranking, :free_tss, :free_tes, :free_pcs, :free_deductions, :free_bv,
           ]
    @hidden_columns = [:competition_type, :competition_class]
    super(data, only: cols)

    @table_keys = {
      competition_name: "competitions.name",
      competition_class: "competitions.competition_class",
      competition_type: "competitions.competition_type",
      category: "results.category",
      season: "competitions.season",
      skater_name: "skaters.name",
      nation: "skaters.nation",
      
    }
    add_filters(:name, :competition_name, :skater_name, operator: :matches)
    add_filters(:category, :nation, :season, :competition_class, :competition_type)

    update_settings(order: [[cols.index(:season), :desc]])
    
  end
end