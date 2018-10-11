class SkatersController < IndexController
  def skater
    @skater ||= Skater.find_by(isu_number: params[:isu_number]) ||
                Skater.find_by(name: params[:isu_number]) ||
                raise(ActiveRecord::RecordNotFound.new('no such skater'))
  end

  def competition_results_datatable(skater)
    columns = [:competition_name, :date, :category, :ranking, :points,
               :short_ranking, :short_tss, :short_tes, :short_pcs, :short_deductions,
               :free_ranking, :free_tss, :free_tes, :free_pcs, :free_deductions,]
    records = skater.category_results.recent.includes(:competition, :short, :free, :category)
    AjaxDatatables::Datatable.new(self).records(records).columns(columns).default_orders([[:date, :desc]])
  end

  def data_to_show
    { skater: skater, competition_results: competition_results_datatable(skater) }
  end
end
