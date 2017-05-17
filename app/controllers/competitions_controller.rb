class CompetitionsListDecorator < Draper::Decorator
  include ListDecorator

  def name
    h.link_to_competition(model)
  end
  
  def site_url
    h.content_tag(:span) do
      h.concat(h.link_to("ISU HP", model.site_url, target: "_blank"))
      h.concat(h.span_link_icon)
    end
  end
end
################################################################
class CompetitionsController < ApplicationController
  def index
    @filters = {
      name: {operator: :like, input: :text_field, model: Competition},
      competition_type: {operator: :eq, input: :select, model: Competition},
      season: {operator: :eq, input: :select, model: Competition},
    }
    @keys = [:cid, :name, :site_url, :city, :country, :competition_type, :season, :start_date, :end_date]
    CompetitionsListDecorator.set_filter_keys([:competition_type, :season])
    collection = Competition.recent.filter(@filters, params)
    render_index_as_formats(collection)
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
