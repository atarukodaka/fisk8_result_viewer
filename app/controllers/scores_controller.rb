class ScoresController < ApplicationController
  def index
    @filters = {
      skater_name: {operator: :like, input: :text_field},
      category: {operator: :eq, input: :select, model: Score},      
      segment: {operator: :eq, input: :select, model: Score},      
      nation: {operator: :eq, input: :select, model: Score},      
      competition_name: {operator: :eq, input: :select, model: Score},      
    }
    
    collection = Score.recent.filter(@filters, params)
    render_formats(collection, page: params[:page])
  end

  def show
    @score = Score.find_by(sid: params[:sid]) ||
      raise(ActiveRecord::RecordNotFound.new("no such sid: '#{params[:sid]}'"))

    respond_to do |format|
      format.html {}
      format.json { render json: {summary: @score, elements: @score.elements, components: @score.components }}
    end
  end
end
