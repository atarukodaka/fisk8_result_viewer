class SkatersController < ApplicationController
  include IndexActions
  
  def get_skater
    Skater.find_by(isu_number: params[:isu_number]) ||
      Skater.find_by(name: params[:isu_number]) || 
      raise(ActiveRecord::RecordNotFound.new("no such skater"))
  end
=begin
  def skater_info_listtable(skater)
    Listtable.new(self).records(skater).columns([:name, :nation, :isu_number, :category])
  end
=end
  def competition_results_datatable(skater)
    columns = [:competition_name, :date, :category, :ranking, :points, :short_ranking, :short_tss, :short_tes, :short_pcs, :short_deductions, :free_ranking, :free_tss, :free_tes, :free_pcs, :free_deductions,]
    #AjaxDatatables::Datatable.new(self).records(skater.category_results.recent.includes(:competition, :scores)).columns(columns).default_orders([[:date, :desc]])
    AjaxDatatables::Datatable.new(self).records(skater.category_results.recent.includes(:competition, :scores)).columns(columns).default_orders([[:date, :desc]])
  end
  def show
    skater = get_skater
    ## render
    respond_to do |format|
      format.html {
        render action: :show, locals: {
                 skater: skater,
                 #skater_summary: skater_info_listtable(skater),
                 competition_results: competition_results_datatable(skater),
               }
      }
      format.json {
        render json: skater.slice(*[:name, :nation, :isu_number, :category]).
               merge(competition_results: competition_results_datatable(skater))
      }
    end
  end
end
