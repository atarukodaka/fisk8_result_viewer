################
class SkatersListDecorator < ListDecorator
  def name
    h.link_to_skater(model)
  end
  def isu_number
    h.link_to_isu_bio(model.isu_number)
  end
end

class SkaterCompetitionsListDecorator < ListDecorator
  include ApplicationHelper

  def competition_name
    h.link_to_competition(nil, model.competition)
  end
  def date
    model.competition.start_date
  end
  def ranking
    h.link_to_competition(as_ranking(model.ranking), model.competition, category: model.category)
  end
  def points
    h.link_to_competition(as_score(model.points), model.competition, category: model.category)
    
  end
  def short_ranking
    h.link_to_score(as_ranking(model.short_ranking), model.scores.first)
  end
  def free_ranking
    h.link_to_score(as_ranking(model.free_ranking), model.scores.first)
  end
  def short_tss
    h.link_to_score(as_score(model.scores.first.try(:tss)), model.scores.first)
  end
  def free_tss
    h.link_to_score(as_score(model.scores.second.try(:tss)), model.scores.second)
  end
end
################################################################
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
  def plot(skater, scores, title: "")
    require 'gnuplot'
    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        plot.terminal "png"
        plot.output   "public/#{title}_plot.png"
        plot.title    title
        plot.xlabel   "x"
        plot.ylabel   "points"
        plot.grid
        plot.yrange   "[0:*]"

        ys = [{key: :tss, color: 3}, {key: :tes, color: 4},{key: :pcs, color: 5},]

        ys.each do |hash|
          y = scores.pluck(hash[:key]).compact # .reject {|v| v == 0 }
          x = scores.pluck(:date).compact.map {|v| v.year.to_f + v.month.to_f/12 + v.day.to_f/365 }
          puts x
          plot.data << Gnuplot::DataSet.new([x, y]) do |ds|
            ds.with      = "linespoints"
            ds.linewidth = 2
            ds.linecolor = hash[:color]
            ds.title = hash[:key].to_s.upcase
          end
        end
      end
    end
    
  end
  def show_skater(skater)
    raise ActiveRecord::RecordNotFound.new("no such skater") if skater.nil?

    collection = skater.category_results.with_competition.recent.includes(:competition, :scores).isu_championships_only_if(params[:isu_championships_only])

    category_results = SkaterCompetitionsListDecorator.decorate_collection(collection)

    ## result summary
    tmp_pcs = Hash.new { |h,k| h[k] = []}
    skater.components.all.each {|c| tmp_pcs[c.number] << c.value}
    max_pcs = {}
    (1..5).each do |i|
      max_pcs[i] = tmp_pcs[i].max
    end
    result_summary = {
      highest_score: collection.pluck(:points).compact.max,
      competitions_participated: collection.count,
      gold_won: collection.where(ranking: 1).count,
      highest_ranking: collection.pluck(:ranking).compact.reject {|d| d == 0}.min,
      most_valuable_element: skater.elements.order(:value).last,
      most_valuable_components: max_pcs || {},
                                        
    }
    #collection = skater.category_results.includes(:competition)
    #category_results = SkaterCompetitionsListDecorator.decorate_collection(collection.includes(:scores).order("scores.date desc"))

    [:short, :free].each do |segment|
      plot(skater, skater.scores.send(segment).recent.isu_championships_only_if(params[:isu_championships_only]), title: "#{skater.name} - #{segment.to_s}")
    end

    respond_to do |format|
      format.html { render action: :show, locals: { skater: skater, category_results: category_results, result_summary: result_summary }}
      format.json { render json: {skater_info: skater, competition_results: skater.category_results} }
    end
  end
end
