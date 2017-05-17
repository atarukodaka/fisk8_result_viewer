################
class SkaterListDecorator < Draper::Decorator # ListDecorator # Draper::Decorator
  include ListDecorator
  
  set_filter_keys(:nation, :category)
  def name
    h.link_to_skater(model)
  end
  def isu_number
    h.link_to(model.isu_number, isu_bio_url(model.isu_number))
  end
end
################################################################
class SkatersController < ApplicationController
  ## index
  def index
    @filters = {
      name: {operator: :like, input: :text_field},
      category: {operator: :eq, input: :select, model: Skater},
      nation: {operator: :eq, input: :select, model: Skater},
    }
    @keys = [ :name, :nation, :category, :isu_number]
    collection = Skater.filter(@filters, params).having_scores

    respond_to do |format|
      format.html { @collection = SkaterListDecorator.decorate_collection(collection.page(params[:page])) }
      format.json { render json: collection.limit(max_output) }
      format.csv {
        @collection = collection.limit(max_output)
        headers['Content-Disposition'] = %Q[attachment; filename="#{controller_name}.csv"]
      }
    end
    #render_formats(collection, page: params[:page])
  end

  ## show
  def show
    @skater = Skater.find_by(isu_number: params[:isu_number]) ||
      raise(ActiveRecord::RecordNotFound.new("no such isu_number in skaters: '#{params[:isu_number]}'"))

    respond_to do |format|
      format.html {}
      format.json { render json: @skater}
    end
  end
  def show_by_name
    @skater = Skater.find_by(name: params[:name]) ||
      raise(ActiveRecord::RecordNotFound.new("no such name in skateres: '#{params[:name]}'"))
    respond_to do |format|
      format.html { render action: :show }
      format.json { render json: @skater}
    end
  end
end
