class Competition < ApplicationRecord
  include FilterModules
  
  after_initialize :set_default_values
  
  has_many :category_results, dependent: :destroy
  has_many :scores, dependent: :destroy

  scope :recent, ->(){
    order("start_date desc")
  }

  def categories
    category_results.pluck(:category).uniq
  end
  def segments(category)
    _segments = Hash.new { |h,k| h[k] = [] }
    scores.pluck(:category, :segment).uniq.each {|cat, seg| _segments[cat] << seg }
    return _segments[category]
  end
  def top_rankers(category)
    _top_rankers = Hash.new { |h,k| h[k] = [] }    
    category_results.includes(:skater).where("ranking >= ? and ranking <= ?", 1, 3).each do |res|
      _top_rankers[res.category][res.ranking] = res.skater
    end
    return _top_rankers[category]
  end

  ## validation
  validates :cid, presence: true, uniqueness: true
  validates :country, allow_nil: true, format: { with: /\A[A-Z][A-Z][A-Z]\Z/}  

  private
  def set_default_values
    self.cid ||= self.name || [self.competition_type, self.country, self.start_date.try(:year)].join("-")
  end
end
