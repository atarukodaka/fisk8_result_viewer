class ScoresListDecorator < ListDecorator
  def sid
    h.link_to_score(model.sid, model)
  end
  def result_pdf
    h.link_to_pdf(model.result_pdf)
  end
end
################################################################
class ScoresController < ApplicationController
  def filters
    #score_filters
    #hash = score_filters
    f = IndexFilters.new
    #f.attributes = score_hash
    f[:skater_name] = {operator: :like, input: :text_field, model: Score}
    f.attributes = score_filters
    f
  end
  def display_keys
    [:sid, :competition_name, :category, :segment, :season, :date, :result_pdf,
     :ranking, :skater_name, :nation, :tss, :tes, :pcs, :deductions, :base_value]
  end
  def collection
    col = Score.joins(:competition).recent.select("competitions.season, scores.*").filter(filters.create_arel_tables(params))
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
