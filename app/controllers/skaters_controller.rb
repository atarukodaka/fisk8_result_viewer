class SkatersController < ApplicationController
  ## index
  def index
    @filters = {
      name: {operator: :like, input: :text_field},
      category: {operator: :eq, input: :select, model: Skater},
      nation: {operator: :eq, input: :select, model: Skater},
    }
    collection = Skater.filter(@filters, params).having_scores
    render_formats(collection, page: params[:page])
  end

  ## show
  def show
    @skater = Skater.find_by(isu_number: params[:isu_number]) ||
      raise(ActiveRecord::RecordNotFound.new("no such isu_number in skaters: '#{params[:isu_number]}'"))

    respond_to do |format|
      format.html {}
      format.json { render json: @skater}
    end
  end
  def show_by_name
    @skater = Skater.find_by(name: params[:name]) ||
      raise(ActiveRecord::RecordNotFound.new("no such name in skateres: '#{params[:name]}'"))
    respond_to do |format|
      format.html { render action: :show }
      format.json { render json: @skater}
    end
  end
end
