class ScoresListDecorator < ListDecorator
  def sid
#    ary = model.sid.split('/')
#    text = [ary.shift, ary.map {|d| d[0]}].join('/')
    h.link_to_score(model.sid, model)
  end
  def result_pdf
    h.link_to_pdf(model.result_pdf)
  end
  def season
    binding.pry
    model.competition.season
  end
  def category
    "SASS"
  end
  
end
################################################################
class ScoresController < ApplicationController
  def filters
    score_filters
  end
  def display_keys
    [:sid, :competition_name, :category, :segment, :season, :date, :result_pdf,
     :ranking, :skater_name, :nation, :tss, :tes, :pcs, :deductions, :base_value]
  end
  def collection
    Score.joins(:competition).recent.filter(filters, params).select("competitions.season, scores.*")
  end
  def show
    score = Score.find_by(sid: params[:sid]) ||
      raise(ActiveRecord::RecordNotFound.new("no such sid: '#{params[:sid]}'"))

    respond_to do |format|
      format.html { render locals: {score: score}}
      format.json { render json: {summary: score, elements: @score.elements, components: @score.components }}
    end
  end
end
