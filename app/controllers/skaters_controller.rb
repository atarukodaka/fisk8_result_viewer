class SkatersController < ApplicationController
  include IndexActions
  
  def get_skater
    Skater.find_by(isu_number: params[:isu_number]) ||
      Skater.find_by(name: params[:isu_number]) || 
      raise(ActiveRecord::RecordNotFound.new("no such skater"))
  end
  def skater_info_listtable(skater)
    Listtable.new(self).records(skater).columns([:name, :nation, :isu_number, :category])
  end
  def record_summary_datatable(skater)
    cr = skater.results
    hash = {
      highest_score: cr.maximum(:points),
      number_of_competitions_participated: cr.count,
      number_of_gold_won: cr.where(ranking: 1).count,
      most_valuable_element: skater.elements.order(:value).last.decorate.description,
      most_valuable_components: skater.components.group(:number).maximum(:value).values.join('/'),
    }
    Listtable.new(self).records(Hashie::Mash.new(hash)).columns(hash.keys)
  end
  def competition_results_datatable(skater)
    columns = [:competition_name, :date, :category, :ranking, :points, :short_ranking, :short_tss, :short_tes, :short_pcs, :short_deductions, :free_ranking, :free_tss, :free_tes, :free_pcs, :free_deductions,]
    Datatable.new(self).records(skater.results.recent.includes(:competition, :scores)).columns(columns).default_orders([[:date, :desc]])
  end
  def create_graphs(skater)    
    skater.scores.order(:date).group_by {|s| s.segment}.map do |segment, scores|
      ScoreGraph.new(scores, title: "#{skater.name} - #{segment}", filename_prefix: "#{skater.name}_#{segment}").tap {|sg|
        sg.plot
      }
    end
  end
    
  def show
    ## render
    respond_to do |format|
      skater = get_skater
      hash = {
        skater_info: skater_info_listtable(skater),
        record_summary: record_summary_datatable(skater),
        competition_results: competition_results_datatable(skater),
      }
      format.html {
        hash.update(skater: skater, score_graphs: create_graphs(skater))
        render action: :show, locals: hash
      }
      format.json {
        render json: hash
      }
    end
  end
end
