class CompetitionsController < ApplicationController
  def index
    @filters = {
      name: {operator: :like, input: :text_field, model: Competition},
      competition_type: {operator: :eq, input: :select, model: Competition},
      season: {operator: :eq, input: :select, model: Competition},
    }
    collection = Competition.recent.filter(@filters, params)
    render_formats(collection, page: params[:page])
  end

  def show
    @competition = Competition.find_by(cid: params[:cid]) || raise(ActiveRecord::RecordNotFound)
    @category = params[:category]
    @segment = params[:segment]

=begin
    respond_to do |format|
      format.html { }
      format.json { render json: @competition }
    end
=end
  end
end
