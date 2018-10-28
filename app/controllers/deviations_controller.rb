class DeviationsController < IndexController
  def show
    deviation = Deviation.find_by!(name: params[:name])

    cols = [:detailable_number, :detailable_name, :value, :average, :deviation]
    base_sql = JudgeDetail.where(official: deviation.official).order(number: :asc).preload(:detailable)
    base_datatable = AjaxDatatables::Datatable.new(view_context).columns(cols)
                     .update_settings(paging: false, searching: false, info: false)

    records = base_sql.where("elements.score": deviation.score).includes(:element)
    tes_deviations_datatable = base_datatable.dup.records(records)

    records = base_sql.where("components.score": deviation.score).includes(:component)
    pcs_deviations_datatable = base_datatable.dup.records(records)

    render :show, locals: {
      deviation: deviation,
             tes_deviations_datatable: tes_deviations_datatable,
             pcs_deviations_datatable: pcs_deviations_datatable
    }
  end
end
