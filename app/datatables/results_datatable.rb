class ResultsDatatable < IndexDatatable
  def initialize(*args)
    super(*args)
    
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

    ## hidden
    [:competition_class, :competition_type].each do |key|
      column_defs[key].visible = false
    end
    self.default_orders = [[:season, :desc]]
  end
  def fetch_records
    Result.includes(:competition, :skater, :scores).references(:competition, :skater).all
  end
end
