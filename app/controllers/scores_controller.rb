class ScoresController < ApplicationController
  include IndexActions
  
  def score_summary(score)
    Listtable.new(score.decorate, only: [:skater_name, :competition_name, :category, :segment, :date, :tss, :tes, :pcs, :deductions, :result_pdf, :youtube_search])

  end
  def elements_datatable(score)
    Datatable.new(score.elements, only: [:number, :name, :element_type, :info, :base_value, :credit, :goe, :judges, :value])
  end

  def components_datatable(score)
    Datatable.new(score.components, only: [:number, :name, :factor, :judges, :value])
  end
  def show
    score = Score.find_by(name: params[:name]) ||
      raise(ActiveRecord::RecordNotFound.new("no such score name: '#{params[:name]}'"))

    respond_to do |format|
      format.html { render locals: {
          score: score,
          score_summary: score_summary(score),
          elements_datatable: elements_datatable(score),
          components_datatable: components_datatable(score)
        }
      }
      format.json {
        render json: score.as_json
          .merge(
                 elememnts: elements_datatable(score),
                 components: components_datatable(score),
                 )
      }
    end
  end
end
