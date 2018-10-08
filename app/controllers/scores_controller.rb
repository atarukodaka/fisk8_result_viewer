class ScoresController < IndexController
  def elements_datatable(score)
    AjaxDatatables::Datatable.new(view_context).records(score.elements)
      .columns([:number, :name, :element_type, :info, :base_value, :credit, :goe, :judges, :value])
  end

  def components_datatable(score)
    AjaxDatatables::Datatable.new(view_context).records(score.components)
      .columns([:number, :name, :factor, :judges, :value])
  end

  def show
    score = Score.find_by!(name: params[:name])
    data = {
      score: score,
      elements:   elements_datatable(score),
      components: components_datatable(score),
    }
    respond_to do |format|
      format.html {     render locals: data }
      format.json {     render json: score }
    end
  end
end
