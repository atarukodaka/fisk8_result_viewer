class ScoresController < IndexController
  def elements_datatable(score)
    AjaxDatatables::Datatable.new(view_context).records(score.elements)
      .columns([:number, :name, :element_type, :info, :base_value, :credit, :goe, :judges, :value])
  end

  def components_datatable(score)
    AjaxDatatables::Datatable.new(view_context).records(score.components)
      .columns([:number, :name, :factor, :judges, :value])
  end

  def data_to_show
    score = Score.find_by!(name: params[:name])
    {
      score: score,
      elements: elements_datatable(score).update_settings(paging: false, info: false)
        .default_orders([[:number, :asc]]),
      components: components_datatable(score).update_settings(paging: false, info: false)
        .default_orders([[:number, :asc]]),
    }
  end
end
