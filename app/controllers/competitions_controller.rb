class CompetitionsController < ApplicationController
  include IndexActions
  include Contracts
  
  def competition_summary(competition)
    Listtable.new(view_context).records(competition).columns([:name, :short_name, :competition_type, :city, :country, :site_url, :start_date, :end_date, :timezone, :comment])
  end
    
  def result_type(category, segment)
    if category.blank? && segment.blank?
      :none
    elsif segment.blank?
      :category
    else
      :segment
    end
  end
  def result_datatable(competition, category, segment)
    case result_type(category, segment)
    when :category
      Datatable.new(view_context).records(competition.results.category(category).includes(:skater, :scores)).columns([:ranking, :skater_name, :nation, :points,
                                                                                                                      :short_ranking, :short_tss, :short_tes, :short_pcs, :short_deductions, :short_bv,
                                                                                                                      :free_ranking, :free_tss, :free_tes, :free_pcs, :free_deductions, :free_bv,]).tap {|d| d.default_orders([[:points, :desc], [:ranking, :asc]])}
      
    when :segment
      Datatable.new(view_context).records(competition.scores.category(category).segment(segment).order(:ranking).includes(:skater, :elements, :components)).
        columns([:ranking, :skater_name, :nation, :starting_number, :tss, :tes, :pcs, :deductions, :elements_summary, :components_summary,]).tap {|d| d.default_orders([[:tss, :desc], [:ranking, :asc]])}
    else
      nil
    end
  end    
  def show
    competition = Competition.find_by(short_name: params[:short_name]) || raise(ActiveRecord::RecordNotFound)

    category, segment = params[:category], params[:segment]
    data = {
      competition_summary: competition_summary(competition),
      result_type: result_type(category, segment),
      results: result_datatable(competition, category, segment),
    }

    respond_to do |format|
      format.html {
        render :show, locals: data.merge(competition: competition,
                                         category: category,
                                         segment: segment,
                                         )
      }
      format.json {
        render json: data
      }
    end
  end
end
