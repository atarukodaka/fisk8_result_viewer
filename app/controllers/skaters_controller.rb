################
class SkatersController < ApplicationController
  ## index
  def filters
    @_filters ||= IndexFilters.new.tap do |f|
      f.filters = {
        name: {operator: :like, input: :text_field, model: Skater},
        category: {operator: :eq, input: :select, model: Skater},
        nation: {operator: :eq, input: :select, model: Skater},
      }
    end
  end
  def display_keys
    [ :name, :nation, :category, :isu_number]
  end
  def collection
    Skater.filter(filters.create_arel_tables(params)).order(:category, :name).having_scores
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
    collection = skater.category_results.recent.includes(:competition, :scores).isu_championships_only_if(params[:isu_championships_only])

    competition_results = SkaterCompetitionDecorator.decorate_collection(collection)

    ################
    ## result summary
    result_summary = SkaterCompetitionResultSummary.new(skater, isu_championships_only: params[:isu_championships_only])
                                                        
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
        render action: :show, locals: { skater: skater.decorate, competition_results: competition_results, result_summary: result_summary }
      }
      format.json {
        render json: {skater_info: skater, competition_results: skater.category_results}
      }
    end
  end
end
