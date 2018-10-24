class StaticsController < ApplicationController
  def index
    season = params[:season] ||= Competition.recent.first.try(:season)
    category = Category.find_by(name: params[:category_type] ||= "MEN")

    cr_cols = [:no, :skater_name, :nation, :competition_name, :points, :short_ranking, :short_tss, :free_ranking, :free_tss]
    cr_records = CategoryResult.includes(:competition, :skater, :short, :free).order(points: :desc)
                 .where("competitions.season" => season, category: category)

    ## segments
    seg_cols = [:no, :skater_name, :nation, :name, :tss, :tes, :pcs]
    seg_records = Score.includes(:competition, :skater).order(tss: :desc)
                  .where("competitions.season" => season, category: category)

    ## elements
    elem_cols = [:no, :skater_name, :score_name, :name, :base_value, :goe, :value]
    elem_records = Element.includes(:score, score: [:competition, :skater])
                   .where("competitions.season" => season, "scores.category" => category)
                   .order(value: :desc).joins(:score, score: [:competition])
    
    
    ## components
    pcs_cols = [:no, :skater_name, :pcs, :component_SS, :component_TR, :component_PE, :component_CO, :component_IN]
    pcs_records = Score.includes(:competition, :skater, :components).order(pcs: :desc).where("competitions.season" => season, category: category)
    
    
    ################
    datatables = {
      scores: {
        total: StaticsDatatable.new(view_context).records(cr_records).columns(cr_cols).decorate,
        short: StaticsDatatable.new(view_context).records(seg_records.short).columns(seg_cols).decorate,
        free: StaticsDatatable.new(view_context).records(seg_records.free).columns(seg_cols).decorate,
      },
      valuable_elements: {},
      pcs: {
        short: StaticsDatatable.new(view_context).records(pcs_records.short).columns(pcs_cols).decorate,
        free: StaticsDatatable.new(view_context).records(pcs_records.free).columns(pcs_cols).decorate,
      },
    }
      [:jump, :spin, :step, :choreo, :lift, :death_spiral].each do |key|
      datatables[:valuable_elements][key] =
        StaticsDatatable.new(view_context).records(elem_records.where(element_type: key)).columns(elem_cols).decorate
    end

    render :index, locals: { season: season, category: category, datatables: datatables}
  end
end
