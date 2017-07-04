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

    ################
    ## competition results
    competition_results = skater.category_results.recent.includes(:competition, :scores)
    
    ################
    ## score graph
    score_graph = ScoreGraph.new
    skater.scores.recent.group_by {|s| s.segment}.each do |segment, segment_scores|
      score_graph.plot(skater, segment_scores, segment)
    end

    ################
    ## render
    respond_to do |format|
      table = Datatable.new(competition_results, columns)
      
      format.html {
        columns = [:competition_name, :date, :category, :ranking, :points, :short_ranking, :short_tss, :short_tes, :short_pcs, :short_deductions, :free_ranking, :free_tss, :free_tes, :free_pcs, :free_deductions,]
        render action: :show, locals: { 
          skater: skater,
          competition_results_table: table,
        }
      }
      format.json {
        render json: skater.as_json.merge({competition_results: table}) # TODO: skater record summary
      }
    end
  end
end
