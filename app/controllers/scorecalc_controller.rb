class ScorecalcController < ApplicationController
  def index
  end

  def load_score
    #render json: {score_id: params[:score_id]}
    render json: ["4T", 0]
  end
end
