class CategorySummary
  include ApplicationHelper
  extend Forwardable
  include Enumerable
  
  def_delegators :@data, :map, :each

  module Decorate
    def decorate
      CategorySummaryDecorator.decorate(self)
    end
  end
  def initialize(competition)
    categories = []
    segments = Hash.new { |h,k| h[k] = [] }
    top_rankers = Hash.new { |h,k| h[k] = [] }

    competition.scores.order("date").pluck(:category, :segment).uniq.each do |cat_seg|
      category, segment = cat_seg
      categories << category unless categories.include?(category)
      segments[category] << segment
    end
    categories = sort_with_preset(categories, ["MEN", "LADIES", "PAIRS", "ICE DANCE"])
    
    competition.category_results.top_rankers(3).each do |item|
      top_rankers[item.category] << item.skater.name
    end
    @data = categories.map do |category|
      { competition: competition, category: category, segments: segments[category], top_rankers: top_rankers[category]}.tap {|h| h.extend Decorate }
    end
  end
end

