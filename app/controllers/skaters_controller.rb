################
class SkatersController < ApplicationController
  ## index
=begin
  def display_keys
    #[ :name, :nation, :category, :isu_number]
  end
=end
  def filters
    {
      name: ->(col, v){ col.matches(:name, v) },
      category: ->(col, v){ col.where(category: v) },
      nation: ->(col, v){ col.where(nation: v) },
    }
  end
  def collection
    col = filter(Skater.order(:category, :name).having_scores)
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
    competition_results = skater.category_results.recent.includes(:competition, :scores).isu_championships_only_if(params[:isu_championships_only])
    
    ################
    ## score graph
    score_graph = ScoreGraph.new
    skater.scores.recent.isu_championships_only_if(params[:isu_championships_only]).group_by {|s| s.segment}.each do |segment, segment_scores|
      score_graph.plot(skater, segment_scores, segment)
    end

    ################
    ## render
    respond_to do |format|
      format.html {
        render action: :show, locals: {
          skater: skater.decorate,
          competition_results: SkaterCompetitionDecorator.decorate_collection(competition_results)
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
