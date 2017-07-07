class ScoresController < ApplicationController
  def create_collection
    Score.includes(:competition, :skater).references(:competition, :skater).all    
  end
  def create_datatable
    #super.add_option(:default_order,  [:date, :desc])
    super
  end
  def columns
    [
     {name: "name", by: "scores.name"},
     {name: "competition_name", by: "competitions.name"},
     {name: "category", by: "scores.category"},
     :segment,
     {name: "season", by: "competitions.season"},
     :date, :result_pdf,
     :ranking,
     {name: "skater_name", by: "skaters.name"},
     {name: "nation", by: "skaters.nation"},
     :tss, :tes, :pcs, :deductions, :base_value,]
  end
  
  ################################################################
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
