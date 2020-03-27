class CompetitionsController < IndexController
  using StringToModel

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

    records = competition.category_results.category(category).includes(:skater, :short, :free)
    CategoryResultsDatatable.new(view_context).records(records)
  end

  def segment_results_datatable(competition, category, segment)
    return nil if category.blank? || segment.blank?

    records = competition.scores.includes(:category, :segment)
              .category(category).segment(segment)
              .order(:ranking).includes(:skater)
    columns = [:ranking, :name, :skater_name, :nation, :starting_number,
               :tss, :tes, :pcs, :deductions, :elements_summary, :components_summary,]
    AjaxDatatables::Datatable.new(view_context).records(records).columns(columns)
      .default_orders([[:tss, :desc], [:ranking, :asc]])
  end

  def time_schedule_datatable(competition)
    records = competition.time_schedules.includes(:category, :segment).order(:starting_time)
    AjaxDatatables::Datatable.new(view_context).records(records)
      .columns([:category_name, :segment_name, :starting_time])
      .update_settings(paging: false, info: false, searching: false)
  end

  def officials_datatable(competition, category, segment)
    return nil if category.nil? || segment.nil?

    records = Official.where(competition: competition, category: category, segment: segment).includes(:panel)
    AjaxDatatables::Datatable.new(view_context).records(records)
      .columns([:function_type, :function, :panel_name, :panel_nation])
      .update_settings(info: false, searching: false, paging: false)
  end

  def data_to_show
    competition = Competition.find_by!(key: params[:key])

    category = params[:category].to_category
    segment = params[:segment].to_segment

    {
      competition: competition,
      category:    category,
      segment:     segment,
      result_type: result_type(category.try(:name), segment.try(:name)),
      category_results: category_results_datatable(competition, category),
      segment_results:  segment_results_datatable(competition, category, segment),
      time_schedule: time_schedule_datatable(competition),
      officials: officials_datatable(competition, category, segment),
    }
  end
end
