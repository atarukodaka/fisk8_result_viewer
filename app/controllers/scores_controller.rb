class ScoreDecorator < EntryDecorator
  class << self
    def headers
      super.merge({deductions: "ded", result_pdf: "pdf",})
    end
  end
  def sid
    h.link_to_score(model.sid, model)
  end
  def result_pdf
    h.link_to_pdf(model.result_pdf)
  end
  def season
    model.competition.season
  end
  def skater_name
    h.link_to_skater(model.skater)
  end
  def competition_name
    h.link_to_competition(model.competition)
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
    #col = Score.with_competition.recent.select("competitions.season, scores.*").filter(filters.create_arel_tables(params))
    #Score.where(id: col.map(&:id)).includes(:competition, :skater)
    filter(Score.includes(:competition, :skater).references(:competition).recent)    #.filter(filters.create_arel_tables(params))

  end
  def show
    score = Score.find_by(sid: params[:sid]) ||
      raise(ActiveRecord::RecordNotFound.new("no such sid: '#{params[:sid]}'"))

    respond_to do |format|
      format.html { render locals: {score: score}}
      format.json { render json: {summary: score, elements: score.elements, components: score.components }}
    end
  end
end
