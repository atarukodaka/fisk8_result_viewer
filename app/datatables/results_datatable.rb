class ResultsDatatable < IndexDatatable
  def initialize(*args)
    super(*args)
    
    add_hidden_columns(:competition_name, :competition_type, :competition_class,
                       :short_tes, :short_pcs,
                       :short_deductions, :short_bv,
                       :free_tes, :free_pcs,
                       :free_deductions, :free_bv,
                       )

    self.columns = [:competition_name, :competition_short_name, :competition_class, :competition_type, :category, :season,
     :ranking, :skater_name, :nation, :points,
     :short_ranking,
     :short_tss, :short_tes, :short_pcs, :short_deductions, :short_bv,
     :free_ranking,
     :free_tss, :free_tes, :free_pcs, :free_deductions, :free_bv,
    ]

    self.sources = {
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

    [:ranking, :points, :short_ranking, :short_tss, :short_tes, :short_pcs, :short_deductions, :short_bv,
     :free_ranking, :free_tss, :free_tes, :free_pcs, :free_deductions, :free_bv,].each do |key|
      self.column_defs[key].operator = :eq
    end
  end
  def fetch_records
    Result.includes(:competition, :skater, :scores).references(:competition, :skater).all
  end
  def default_orders
    [[:season, :desc]]
  end
end
