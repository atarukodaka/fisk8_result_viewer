class CompetitionsController < ApplicationController
  using SortWithPreset
  include Contracts
  def competition_info(competition)
    Listtable.new(competition, only: [:name, :short_name, :competition_type, :city, :country, :site_url, :start_date, :end_date, :comment])
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
    settings = {info: false, paging: false}
    case result_type(category, segment)
    when :category
      Datatable.new(competition.category_results.category(category).includes(:skater, :scores),
                    only: [:ranking, :skater_name, :nation, :points, :short_ranking, :short_tss, :free_ranking, :free_tss], settings: settings)
    when :segment
      Datatable.new(competition.scores.category(category).segment(segment).order(:ranking).includes(:skater, :elements, :components),
                    only: [:ranking, :skater_name, :nation, :starting_number, :tss, :tes, :pcs, :deductions, :elements_summary, :components_summary,], settings: settings)
    else
      nil
    end
  end    
  def show
    competition = Competition.find_by(short_name: params[:short_name]) || raise(ActiveRecord::RecordNotFound)

    category = params[:category]
    segment = params[:segment]

    respond_to do |format|
      locals = {
        competition: competition,
        category: category,
        segment: segment,
        competition_info: competition_info(competition),
        result_type: result_type(category, segment),
        result_datatable: result_datatable(competition, category, segment).try(:decorate),
      }

      format.html {
        render :show, locals: locals
      }
      format.json {
        render json: competition.as_json.merge({results: result_datatable(competition, category, segment)})
      }
    end
  end
end
