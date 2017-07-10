class SkatersController < ApplicationController
  ## controller specific
  def fetch_rows
    Skater.having_scores
  end
  def order
    [[:name, :asc]]
  end
  def columns
    [:name, :nation, :category, :isu_number]
  end
  
  ################################################################
  def get_skater
    Skater.find_by(isu_number: params[:isu_number]) ||
      Skater.find_by(name: params[:isu_number]) || 
      raise(ActiveRecord::RecordNotFound.new("no such skater"))
  end
  def get_tables(skater)
    cr = skater.category_results
    record_summary_hash = {
      highest_score: cr.maximum(:points),
      number_of_competitions_participated: cr.count,
      number_of_gold_won: cr.where(ranking: 1).count,
      most_valuable_element: skater.elements.order(:value).last.decorate.description,
      most_valuable_components: skater.components.group(:number).maximum(:value).values.join('/'),
    }
    
    ## tables
    {
      skater_info: Listtable.new(skater, [:name, :nation, :isu_number, :category]),
      record_summary: Listtable.new(Hashie::Mash.new(record_summary_hash)),
      competition_results: Datatable.new(skater.category_results.recent.includes(:competition, :scores), [:competition_name, :date, :category, :ranking, :points, :short_ranking, :short_tss, :short_tes, :short_pcs, :short_deductions, :free_ranking, :free_tss, :free_tes, :free_pcs, :free_deductions,]),
    }
  end
  def create_graphs(skater)    
    skater.scores.order(:date).group_by {|s| s.segment}.map do |segment, scores|
      ScoreGraph.new(scores, title: "#{skater.name} - #{segment}", filename_prefix: "#{skater.name}_#{segment}").tap {|sg|
        sg.plot
      }
    end
  end
    
  def show
    skater = get_skater
    tables = get_tables(skater)
    score_graphs = create_graphs(skater)
    ## render
    respond_to do |format|
      format.html {
        render action: :show, locals: {
          skater: skater, score_graphs: score_graphs, tables: tables
        }
      }
      format.json {
        render json: tables
      }
    end
  end
end
