class SkaterCompetitionResultSummary
  extend Forwardable
  def_delegators :@result_summary, :[]
  
  def initialize(skater, isu_championships_only: false)
    @skater = skater
    @category_results = skater.category_results.isu_championships_only_if(isu_championships_only)
    @isu_champions_only = isu_championships_only
=begin
    collection = skater.category_results.isu_championships_only_if(isu_championships_only)
    tmp_pcs = Hash.new { |h,k| h[k] = []}
    skater.components.isu_championships_only_if(isu_championships_only).each {|c| tmp_pcs[c.number] << c.value}
    max_pcs = {}
    (1..5).each do |i|
      max_pcs[i] = tmp_pcs[i].max
    end
    binding.pry
    @result_summary = {
      highest_score: collection.pluck(:points).compact.max,
      competitions_participated: collection.count,
      gold_won: collection.where(ranking: 1).count,
      highest_ranking: collection.pluck(:ranking).compact.reject {|d| d == 0}.min,
      most_valuable_element: skater.elements.isu_championships_only_if(isu_championships_only).order(:value).last,
      most_valuable_components: max_pcs || {},
    }
=end
  end
  def highest_score
    @category_results.pluck(:points).compact.max
  end
  def competitions_participated
    @category_results.count
  end
  def gold_won
    @category_results.where(ranking: 1).count
  end
  def highest_ranking
    @category_results.pluck(:ranking).compact.reject {|d| d == 0}.min
  end

  def most_valuable_element
    if (elem = @skater.elements.isu_championships_only_if(@isu_championships_only).order(:value).last)
      "%s %s%s (%.2f=%.2f+%.2f)" % [ elem.element, elem.credit, elem.info, elem.value, elem.base_value, elem.goe]
    else
      "-"
    end
  end
  def most_valuable_components
    @skater.components.isu_championships_only_if(@isu_championships_only).group(:number).maximum(:value).values.join('/')
  end
end
class SkaterCompetitionResultSummaryDecorator < EntryDecorator
end

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
  ################
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
    collection = skater.category_results.with_competition.recent.includes(:competition, :scores).isu_championships_only_if(params[:isu_championships_only])

    competition_results = SkaterCompetitionDecorator.decorate_collection(collection)

    ################
    ## result summary
    result_summary = SkaterCompetitionResultSummary.new(skater, isu_championships_only: params[:isu_championships_only])
                                                        
    ################
    ## score graph
    score_graph = ScoreGraph.new
    [:short, :free].each do |segment_type|
      score_graph.plot(skater, skater.scores.send(segment_type).recent.isu_championships_only_if(params[:isu_championships_only]), segment_type)
    end

    ################
    ## render
    respond_to do |format|
      format.html {
        render action: :show, locals: { skater: skater, competition_results: competition_results, result_summary: result_summary }
      }
      format.json {
        render json: {skater_info: skater, competition_results: skater.category_results}
      }
    end
  end
end
