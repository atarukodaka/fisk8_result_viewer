class SkatersController < IndexController
  def get_skater
    Skater.find_by(isu_number: params[:isu_number]) ||
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

  def show
    skater = get_skater
    ## render
    respond_to do |format|
      data = { competition_results: competition_results_datatable(skater) }
      format.html {
        render action: :show, locals: { skater: skater }.merge(data)
      }
      format.json {
        render json: skater.slice(*[:name, :nation, :isu_number, :category]).merge(data)
      }
    end
  end
end
