class ScorecalcController < ApplicationController
  def index
  end

  def load_score
    score_name = params[:score_name]
    score = Score.find_by(name: score_name)
    render json: score.elements.sort_by {|e| e.number }.map {|element| {name: element.name, credit: element.credit, goe: element.goe}}
  end
end
