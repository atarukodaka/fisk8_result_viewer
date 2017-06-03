class ScoreDecorator < EntryDecorator
  class << self
    def headers
      super.merge({deductions: "ded", result_pdf: "pdf",})
    end
  end
  def sid
    h.link_to_score(model.sid, model)
  end
  def skater
    h.link_to_skater(model.skater)
  end
  def competition
    h.link_to_competition(model.competition)
  end
  def category
    h.link_to_competition(model.competition, category: model.category)
  end
  def segment
    h.link_to_competition(model.competition, category: model.category, segment: model.segment)
  end
  def season
    model.competition.season
  end
  def result_pdf
    h.link_to_pdf(model.result_pdf)
  end
  def youtube_search
    h.link_to("Youtube", "http://www.youtube.com/results?q=" + ERB::Util.html_escape([score.skater_name, score.competition_name, score.segment].join('+')), target: "_blank")
  end
end
################################################################
class ScoresController < ApplicationController
  def display_keys
    [:sid, :competition, :category, :segment, :season, :date, :result_pdf,
     :ranking, :skater, :nation, :tss, :tes, :pcs, :deductions, :base_value]
  end
  def collection
    Score.recent.includes(:competition, :skater).filter(filters.create_arel_tables(params))
  end
  def show
    score = Score.find_by(sid: params[:sid]) ||
      raise(ActiveRecord::RecordNotFound.new("no such sid: '#{params[:sid]}'"))

    respond_to do |format|
      format.html { render locals: {score: score.decorate}}
      format.json { render json: {summary: score, elements: score.elements, components: score.components }}
    end
  end
end
