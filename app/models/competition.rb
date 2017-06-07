class Competition < ApplicationRecord
  after_initialize :set_default_values

  ## relations
  has_many :category_results, dependent: :destroy
  has_many :scores, dependent: :destroy

  
  ## validations
  validates :cid, presence: true, uniqueness: true
  validates :country, allow_nil: true, format: { with: /\A[A-Z][A-Z][A-Z]\Z/}  

  ## scopes
  scope :recent, ->(){ order("start_date desc")  }

  ## class methods
  class << self
    def destroy_existings_by_url(url)
      ActiveRecord::Base.transaction {
        Competition.where(site_url: url).map(&:destroy)
      }
    end
  end
  private
  def set_default_values
    self.cid ||= self.name || [self.competition_type, self.country, self.start_date.try(:year)].join("-")
  end
end
