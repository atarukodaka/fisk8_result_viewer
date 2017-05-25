class ScoresListDecorator < ListDecorator
  class << self
    def headers
      super.merge ({
                     deductions: "ded",
                     result_pdf: "pdf",
                   })
    end
  end
  def sid
    h.link_to_score(model.sid, model)
  end
  def result_pdf
    h.link_to_pdf(model.result_pdf)
  end
end
################################################################
class ScoresController < ApplicationController
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
      format.json { render json: {summary: score, elements: score.elements, components: socore.components }}
    end
  end
end
