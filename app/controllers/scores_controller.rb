################################################################
class ScoresController < ApplicationController
  def filters
    score_filters
  end
  def collection
    filter(Score.includes(:competition, :skater).references(:competition).recent)
  end
  ################################################################
  def show
    score = Score.find_by(sid: params[:sid]) ||
      raise(ActiveRecord::RecordNotFound.new("no such sid: '#{params[:sid]}'"))

    respond_to do |format|
      format.html { render locals: {score: score}}
      #format.json { render json: {summary: score, elements: score.elements, components: score.components }}
      format.json { render :show, handlers: :jbuilder, locals: {score: score } }
    end
  end
end
