class ScoresController < ApplicationController
  include IndexActions
  
=begin
  def score_summary(score)
    Listtable.new(view_context).records(score).columns([:skater_name, :competition_name, :category, :segment, :segment_starting_time, :tss, :tes, :pcs, :deductions, :result_pdf, :scorecalc])

  end
=end

  def elements_datatable(score)
    AjaxDatatables::Datatable.new(view_context).records(score.elements).columns([:number, :name, :element_type, :info, :base_value, :credit, :goe, :judges, :value])
  end

  def components_datatable(score)
    AjaxDatatables::Datatable.new(view_context).records(score.components).columns([:number, :name, :factor, :judges, :value])
  end
  def show
    score = Score.find_by(name: params[:name]) ||
      raise(ActiveRecord::RecordNotFound.new("no such score name: '#{params[:name]}'"))

    respond_to do |format|
      format.html {
        render locals: {
                 score: score,
                 elements: elements_datatable(score),
                 components: components_datatable(score),
               }
      }
      format.json {
        render json: 
                 score.slice(*[:name, :competition_name, :category, :segment, :segment_starting_time,
                               :tss, :tes, :pcs, :deductions, :result_pdf]).
                merge({elements: elements_datatable(score),
                       components: components_datatable(score)})
      }
    end
  end
end
