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

=begin
    columns = [:ranking, :skater_name, :nation, :points,
               :short_ranking, :short_tss, :short_tes, :short_pcs, :short_deductions, :short_base_value,
               :free_ranking, :free_tss, :free_tes, :free_pcs, :free_deductions, :free_base_value]
    AjaxDatatables::Datatable.new(view_context)
      .records(competition.category_results.category(category).includes(:skater, :short, :free))
      .columns(columns).default_orders([[:points, :desc], [:ranking, :asc]])
=end
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
    records = competition.performed_segments.includes(:category, :segment).order(:starting_time)
    AjaxDatatables::Datatable.new(view_context).records(records).columns([:category_name, :segment_name, :starting_time]).update_settings(paging: false, info: false, searching: false)
  end

  def officials_datatable(competition, category, segment)
    return nil if category.nil? || segment.nil?
    #records = competition.performed_segments.where(category: category, segment: segment).first.officials.includes(:panel)
    ps = competition.performed_segments.where(category: category, segment: segment)
    records = Official.where(performed_segment: ps).includes(:panel)
#    records = Official.where("performed_segments.competition": competition,
#                             "performed_segments.category": category,
#                             "performed_segments.segment": segment).includes(:performed_segment, :panel)
    AjaxDatatables::Datatable.new(view_context).records(records).columns([:number, :panel_name, :panel_nation]).update_settings(info: false, searching: false, paging: false )
  end

  def data_to_show
    competition = Competition.find_by!(short_name: params[:short_name])

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
