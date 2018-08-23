class ScoresController < ApplicationController
  include IndexActions
  
  def score_summary(score)
    Listtable.new(view_context).records(score).columns([:skater_name, :competition_name, :category, :segment, :segment_starting_time, :tss, :tes, :pcs, :deductions, :result_pdf, :scorecalc])

  end
  def elements_datatable(score)
    AjaxDatatables::Datatable.new(view_context).records(score.elements).columns([:number, :name, :element_type, :info, :base_value, :credit, :goe, :judges, :value])
  end

  def components_datatable(score)
    AjaxDatatables::Datatable.new(view_context).records(score.components).columns([:number, :name, :factor, :judges, :value])
  end
  def show
    score = Score.find_by(name: params[:name]) ||
      raise(ActiveRecord::RecordNotFound.new("no such score name: '#{params[:name]}'"))

    data = {
      score: score,
      score_summary: score_summary(score),
      elements: elements_datatable(score),
      components: components_datatable(score)
    }
    
    respond_to do |format|
      format.html { render locals: data.merge(score: score)  }
      format.json {
        render json: data
      }
    end
  end
end
