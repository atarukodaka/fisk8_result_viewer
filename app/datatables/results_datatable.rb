class ResultsDatatable < IndexDatatable
  def initialize(*args)
    super(*args)
    
    add_hidden_columns(:competition_name, :competition_type, :competition_class,
                       :short_tes, :short_pcs,
                       :short_deductions, :short_bv,
                       :free_tes, :free_pcs,
                       :free_deductions, :free_bv,
                       )
    
    @sources = {
      competition_name: "competitions.name",
      competition_short_name: "competitions.short_name",    
      competition_class: "competitions.competition_class",
      competition_type: "competitions.competition_type",
      category: "results.category",
      season: "competitions.season",
      skater_name: "skaters.name",
      nation: "skaters.nation",
      ranking: "results.ranking",

    }
    add_filters(:competition_name, :skater_name, operator: :matches)
    add_filters(:category, :season, :competition_class, :competition_type)

    settings.update(order: [[columns.index(:season), :desc]])
    
  end
  def fetch_records
    Result.includes(:competition, :skater, :scores).references(:competition, :skater).all
  end
  def columns
    [:competition_name, :competition_short_name, :competition_class, :competition_type, :category, :season,
     :ranking, :skater_name, :nation, :points,
     :short_ranking,
     :short_tss, :short_tes, :short_pcs, :short_deductions, :short_bv,
     :free_ranking,
     :free_tss, :free_tes, :free_pcs, :free_deductions, :free_bv,
    ]
  end
    
end
