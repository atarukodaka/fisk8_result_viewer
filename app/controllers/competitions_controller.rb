class CompetitionsController < IndexController
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

    columns = [:ranking, :skater_name, :nation, :points,
               :short_ranking, :short_tss, :short_tes, :short_pcs, :short_deductions, :short_base_value,
               :free_ranking, :free_tss, :free_tes, :free_pcs, :free_deductions, :free_base_value]
    AjaxDatatables::Datatable.new(view_context)
      .records(competition.category_results.category(category).includes(:skater, :short, :free))
      .columns(columns).default_orders([[:points, :desc], [:ranking, :asc]])
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

  def data_to_show
    competition = Competition.find_by!(short_name: params[:short_name])

    category_name, segment_name = params[:category], params[:segment]
    category = Category.find_by(name: category_name)
    segment = Segment.find_by(name: segment_name)

    {
      competition: competition,
      category:    category,
      segment:     segment,
      result_type: result_type(category_name, segment_name),
      category_results: category_results_datatable(competition, category),
        segment_results:  segment_results_datatable(competition, category, segment),
    }
  end
end
