class ScoresListDecorator < Draper::Decorator
  include ListDecorator

  def sid
    h.link_to_score(model.sid, model)
  end
  def result_pdf
    h.link_to_pdf(model.result_pdf)
  end
end

################################################################
class ScoresController < ApplicationController
  def index
    @filters = {
      skater_name: {operator: :like, input: :text_field},
      category: {operator: :eq, input: :select, model: Score},      
      segment: {operator: :eq, input: :select, model: Score},      
      nation: {operator: :eq, input: :select, model: Score},      
      competition_name: {operator: :eq, input: :select, model: Score},      
    }
    @keys = [:sid, :competition_name, :category, :segment, :date, :result_pdf,
             :ranking, :skater_name, :nation, :tss, :tes, :pcs, :deductions]
    ScoresListDecorator.set_filter_keys(@filters.keys)
    collection = Score.recent.filter(@filters, params)
    render_index_as_formats(collection, decorator: ScoresListDecorator)
  end

  def show
    @score = Score.find_by(sid: params[:sid]) ||
      raise(ActiveRecord::RecordNotFound.new("no such sid: '#{params[:sid]}'"))

    respond_to do |format|
      format.html {}
      format.json { render json: {summary: @score, elements: @score.elements, components: @score.components }}
    end
  end
end
