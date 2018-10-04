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
    score = Score.find_by(name: params[:name]) ||
            raise(ActiveRecord::RecordNotFound.new("no such score name: '#{params[:name]}'"))

    respond_to do |format|
      data = {
        elements:   elements_datatable(score),
        components: components_datatable(score),
      }
      format.html {
        render locals: data.merge(score: score)
      }
      format.json {
        render json: score.slice(*[:name, :competition_name, :date,
                                   :tss, :tes, :pcs, :deductions, :result_pdf]).merge(data)
                .merge(category: score.category.name, segment: score.segment.name)
      }
    end
  end
end
