class StaticsController < ApplicationController
  def index
  end
=begin
  def index
    unless Rails.env.development?
      render plain: "works for only development"
    else
      category = params[:category].presence || "MEN"
      season =  params[:season].presence || "2017-18"   # TODO: recent season
      competition_class = params[:competition_class]
      
      common_sql = {"competitions.season": season}
      common_sql.update("competitions.competition_class": competition_class) if competition_class.present?
      
      results = CategoryResult.joins(:competition, :skater, :scores).where(common_sql).where(category: category)
      scores = Score.joins(:competition, :skater).where(common_sql).where(category: category)
      short_scores = scores.short
      free_scores = scores.free
      elements = Element.joins(score: [:skater, :competition, :elements]).where(common_sql).where("scores.category": category)
      components = Component.joins(score: [:skater, :competition, :elements]).where(common_sql).where("scores.category": category)
      
      render locals: {
               category: category,
               season: season,
               
               results: results,
               short_scores: short_scores,
               free_scores: free_scores,
               elements: elements,
               components: components,
             }
    end
  end
=end
end

