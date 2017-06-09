class SkatersController < ApplicationController
  ## index
  def filters
    {
      name: ->(col, v){ col.matches(:name, v) },
      category: ->(col, v){ col.where(category: v) },
      nation: ->(col, v){ col.where(nation: v) },
    }
  end
  def collection
    filter(Skater.order(:category, :name).having_scores)
  end
  ################################################################
  ## show
  def show
    show_skater(Skater.find_by(isu_number: params[:isu_number]))
  end
  def show_by_name
    show_skater(Skater.find_by(name: params[:name]))
  end
  def show_skater(skater)
    raise ActiveRecord::RecordNotFound.new("no such skater") if skater.nil?

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
      format.html {
        render action: :show, locals: {
          skater: skater.decorate,
          competition_results: competition_results.decorate
        }
      }
      format.json {
        render :show, handlers: :jbuilder, locals: {
          skater: skater,
          competition_results: competition_results
        }
      }
    end
  end
end
