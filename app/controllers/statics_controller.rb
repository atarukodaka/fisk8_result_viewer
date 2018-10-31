class StaticsController < ApplicationController
  def index
    season = params[:season] ||= Competition.recent.first.try(:season)
    category = Category.find_by(name: params[:category_type] ||= 'MEN')

    ## category results
    cr_cols = [:no, :skater_name, :nation, :competition_name, :points, :short_ranking, :short_tss,
               :free_ranking, :free_tss]
    cr_records = CategoryResult.includes(:competition, :skater, :short, :free).order(points: :desc)
                 .where('competitions.season' => season, category: category).limit(10)
    ## segments
    seg_cols = [:no, :skater_name, :nation, :competition_name, :name, :tss, :tes, :pcs]
    seg_records = Score.joins(:competition, :skater).includes(:skater, :competition).order(tss: :desc)
                  .where('competitions.season' => season, category: category).limit(10)
    ## elements
    elem_cols = [:no, :skater_name, :score_name, :name, :base_value, :goe, :value]
    elem_records = Element.includes(score: [:skater])
                   .where('competitions.season' => season, 'scores.category' => category)
                   .order(value: :desc).joins(:score, score: [:competition]).limit(10)
    ## components
    pcs_cols = [:no, :skater_name, :score_name, :pcs,
                :component_SS, :component_TR, :component_PE, :component_CO, :component_IN]
    pcs_records = Score.joins(:competition).includes(:components, :skater).order(pcs: :desc)
                  .where('competitions.season' => season, category: category).limit(10)

    datatables = {
      scores: { total: StaticsDatatable.new(view_context).records(cr_records).columns(cr_cols).decorate },
      valuable_elements: {},
      pcs: {},
    }
    [:jump, :spin, :step, :choreo, :lift, :death_spiral].each do |key|
      datatables[:valuable_elements][key] = StaticsDatatable.new(view_context)
                                            .records(elem_records.where(element_type: key))
                                            .columns(elem_cols).decorate
    end
    [:short, :free].each do |key|
      datatables[:scores][key] = StaticsDatatable.new(view_context)
                                 .records(seg_records.send(key)).columns(seg_cols).decorate
      datatables[:pcs][key] = StaticsDatatable.new(view_context)
                              .records(pcs_records.send(key)).columns(pcs_cols).decorate
    end
    render :index, locals: { season: season, category: category, datatables: datatables }
  end
end
