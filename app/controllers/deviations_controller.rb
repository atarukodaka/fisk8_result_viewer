class DeviationsController < IndexController
  def show
    deviation = Deviation.find_by!(name: params[:name])

    cols = [:detailable_number, :detailable_name, :value, :average, :deviation]

    base_sql = JudgeDetail.where(official: deviation.official).order(number: :asc).preload(:detailable)
    base_datatable = AjaxDatatables::Datatable.new(view_context).columns(cols)
                     .update_settings(paging: false, searching: false, info: false)

    #joins = "INNER JOIN elements ON elements.id = judge_details.detailable_id"
    records = base_sql.where(detailable_type: "Element", "elements.score_id": deviation.score.id).joins(:element)
    tes_deviations_datatable = base_datatable.dup.records(records)

    #joins = "INNER JOIN components ON components.id = judge_details.detailable_id"
    records = base_sql.where(detailable_type: "Component", "components.score_id": deviation.score.id).joins(:component) 
    pcs_deviations_datatable = base_datatable.dup.records(records)

    render :show, locals: {
      deviation: deviation,
             tes_deviations_datatable: tes_deviations_datatable,
             pcs_deviations_datatable: pcs_deviations_datatable
    }
  end
end
