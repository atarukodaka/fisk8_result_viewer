class ScoresController < ApplicationController
  def show
    score = Score.find_by(name: params[:name]) ||
      raise(ActiveRecord::RecordNotFound.new("no such score name: '#{params[:name]}'"))

    respond_to do |format|
      format.html { render locals: {score: score}}
      #format.json { render :show, handlers: :jbuilder, locals: {score: score } }
      format.json { render json: score.as_json.merge({elememnts: score.elements, components: score.components })}
    end
  end
end
