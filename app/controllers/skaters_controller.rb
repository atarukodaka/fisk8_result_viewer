class SkatersController < ApplicationController
  def filters
    {
      name: ->(col, v){ col.where("name like ? ", "%#{v}%") },
      category: ->(col, v){ col.where(category: v) },
      nation: ->(col, v){ col.where(nation: v) },
    }
  end
  def create_collection
    Skater.having_scores
  end
  def columns
    [:name, :nation, :category, :isu_number]
  end
  ################################################################
  ## show
  def show
    skater = Skater.find_by(isu_number: params[:isu_number]) ||
      Skater.find_by(name: params[:isu_number]) || 
      raise(ActiveRecord::RecordNotFound.new("no such skater"))

    cr = skater.category_results
    record_summary_hash = {
      highest_score: cr.maximum(:points),
      number_of_competitions_participated: cr.count,
      number_of_gold_won: cr.where(ranking: 1).count,
      most_valuable_element: skater.elements.order(:value).last.decorate.description,
      most_valuable_components: skater.components.group(:number).maximum(:value).values.join('/'),
    }
    
    ## tables
    tables = {
      skater_info_table: Listtable.new(skater.decorate, [:name, :nation, :isu_number, :category]),
      record_summary_table: Listtable.new(Hashie::Mash.new(record_summary_hash)),
      competition_results_table: Datatable.new(skater.category_results.recent.includes(:competition, :scores), [:competition_name, :date, :category, :ranking, :points, :short_ranking, :short_tss, :short_tes, :short_pcs, :short_deductions, :free_ranking, :free_tss, :free_tes, :free_pcs, :free_deductions,]),
    }
    ## score graph
    score_graphs = skater.scores.order(:date).group_by {|s| s.segment}.map do |segment, scores|
      ScoreGraph.new(skater, segment, scores).tap {|sg|
        sg.plot
      }
    end
    
    ## render
    respond_to do |format|
      format.html {
        render action: :show, locals: { skater: skater, score_graphs: score_graphs}.merge(tables)
      }
      format.json {
        render json: {
          skater_info: tables[:skater_info_table],
          record_summary_table: tables[:record_summary_table],
          competition_results: tables[:competition_results_table],
        }
      }
    end
  end
end
