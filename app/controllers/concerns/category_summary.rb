class CategorySummaryRelation
  extend Forwardable
  include Enumerable
  include Draper::Decoratable
  
  def_delegators :@collection, :each
  
  def initialize(collection)
    @collection = collection
  end
  def decorator_class
    Draper::CollectionDecorator
  end
end

class CategorySummary
  attr_reader :competition, :category, :short, :free, :top_rankers
  include Draper::Decoratable

  class << self
    include ApplicationHelper
  
    def create_summaries(competition)
      categories = []
      segments = Hash.new { |h,k| h[k] = [] }
      top_rankers = Hash.new { |h,k| h[k] = [] }

      competition.scores.order("date").pluck(:category, :segment).uniq.each do |cat_seg|
        category, segment = cat_seg
        categories << category unless categories.include?(category)
        segments[category] << segment
      end
      categories = sort_with_preset(categories, ["MEN", "LADIES", "PAIRS", "ICE DANCE"])

      competition.category_results.includes(:skater).top_rankers(3).each do |item|
        top_rankers[item.category] << item.skater.name
      end
      CategorySummaryRelation.new(categories.map do |category|
        new(competition, category, segments[category].first, segments[category].second, top_rankers[category])
      end)
    end
  end

  def initialize(competition, category, short, free, top_rankers = Array.new(3))
    @competition = competition
    @category = category;
    @short = short
    @free = free
    @top_rankers = top_rankers
  end
end
