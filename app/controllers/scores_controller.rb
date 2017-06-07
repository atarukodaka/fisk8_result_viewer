################################################################
class ScoresController < ApplicationController
  def filters
    {
      skater_name: ->(col, v){ col.references(:skater).matches("skaters.name", v) },
      category: ->(col, v)   { col.where(category: v) },
      segment: ->(col, v)    { col.where(segment:  v) },
      nation: ->(col, v)     { col.where(skaters: {nation: v}) },
      competition_name: ->(col, v)     { col.where(competitions: {name: v}) },
      isu_championships_only:->(col, v){ col.where(competitions: {isu_championships: v =~ /true/i}) },
      season: ->(col, v){ col.where(competitions: {season: v}) },
    }
  end
  def collection
    filter(Score.includes(:competition, :skater).recent)
  end
  ################################################################
  def show
    score = Score.find_by(sid: params[:sid]) ||
      raise(ActiveRecord::RecordNotFound.new("no such sid: '#{params[:sid]}'"))

    respond_to do |format|
      format.html { render locals: {score: score}}
      format.json { render :show, handlers: :jbuilder, locals: {score: score } }
    end
  end
end
