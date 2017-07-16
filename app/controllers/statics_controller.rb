class StaticsController < ApplicationController
  def index
    render locals: {
      category: params[:category].presence || "MEN",
      season: params[:season].presence || "2016-17",
    }
      
  end
end
