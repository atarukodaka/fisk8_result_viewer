class CompetitionsController < ApplicationController
  include IndexActions
  
  def result_type(category, segment)
    if category.blank? && segment.blank?
      :none
    elsif segment.blank?
      :category
    else
      :segment
    end
  end
  def category_results_datatable(competition, category)
    return nil if category.blank?
    AjaxDatatables::Datatable.new(view_context).records(competition.category_results.category(category).includes(:skater, :scores)).
      columns([:ranking, :skater_name, :nation, :points, :short_ranking, :short_tss, :short_tes, :short_pcs, :short_deductions, :short_base_value, :free_ranking, :free_tss, :free_tes, :free_pcs, :free_deductions, :free_base_value,]).tap {|d| d.default_orders([[:points, :desc], [:ranking, :asc]])}
  end
  def segment_results_datatable(competition, category, segment)
    return nil if category.blank? || segment.blank?
    AjaxDatatables::Datatable.new(view_context).records(competition.scores.category(category).segment(segment).order(:ranking).includes(:skater)).  ## , :elements, :components
      columns([:ranking, :name, :skater_name, :nation, :starting_number, :tss, :tes, :pcs, :deductions, :elements_summary, :components_summary,]).tap {|d| d.default_orders([[:tss, :desc], [:ranking, :asc]])}
  end

  def show
    competition = Competition.find_by(short_name: params[:short_name]) || raise(ActiveRecord::RecordNotFound)

    category, segment, ranking = params[:category], params[:segment], params[:ranking]

    if ranking.present?
      # redirect /OWG2018/MEN/SHORT PROGRAM/1 => /scores/OWG2018-MS-1
      score = competition.scores.where(category: category, segment: segment, ranking: ranking).first ||
              raise(ActiveRecord::RecordNotFound.new("no such score: " + [competition.short_name, category, segment, ranking].join('/')))
      
      respond_to do |format|
        format.html {
          redirect_to(controller: :scores, action: :show, name: score.name)
        }
        format.json {
          redirect_to(controller: :scores, action: :show, name: score.name, format: :json)
        }
      end
    else
      respond_to do |format|
        results = {
          category_results: category_results_datatable(competition, category),
          segment_results: segment_results_datatable(competition, category, segment),
        }
        format.html {
          data = {
            competition: competition,
            category: category,
            segment: segment,
            result_type: result_type(category, segment),
          }.merge(results)
          render :show, locals: data
        }
        format.json {
          render json: competition.slice(*[:name, :short_name, :competition_class, :competition_type,
                                           :city, :country, :start_date, :end_date, :timezone, :comment]).merge(results)
        }
      end
    end
  end
end
