################################################################
class ScoresController < ApplicationController
  def filters
    {
      skater_name: ->(col, v){ col.references(:skater).where("skaters.name like ? ", "%#{v}%") },
      category: ->(col, v)   { col.where(category: v) },
      segment: ->(col, v)    { col.where(segment:  v) },
      nation: ->(col, v)     { col.where(skaters: {nation: v}) },
      competition_name: ->(col, v)     { col.references(:competition).where("competitions.name like ? ", "%#{v}%")},
      isu_championships_only:->(col, v){ col.where(competitions: {isu_championships: v.to_bool}) },
      season: ->(col, v){ col.where(competitions: {season: v}) },
    }
  end
  def create_collection
    #Score.includes(:competition, :skater).recent
    Score.includes(:competition, :skater).all    
  end
  def columns
    {
      name: "scores.name", competition_name: "competitions.name", category: "category",
      segment: "segment", season: "season", date: "date", result_pdf: "result_pdf",
      ranking: "ranking", skater_name: "skaters.name", nation: "skaters.nation",
      tss: "tss", tes: "tes", pcs: "pcs", deductions: "deductions", base_value: "base_value"
    }
  end
  
  ################################################################
  def show
    score = Score.find_by(name: params[:name]) ||
      raise(ActiveRecord::RecordNotFound.new("no such score name: '#{params[:name]}'"))

    respond_to do |format|
      format.html { render locals: {score: score}}
      format.json { render :show, handlers: :jbuilder, locals: {score: score } }
    end
  end
end
