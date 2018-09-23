class CategoryResult < ApplicationRecord
  ## relations
  #has_many :scores
  
  belongs_to :competition
  belongs_to :skater
  belongs_to :category
  
  belongs_to :short, class_name: "Score", optional: true  # required: true on default. see https://github.com/rails/rails/issues/18233
  belongs_to :free, class_name: "Score", optional: true
  
  ## virtual attributes
  def competition_name
    competition.name
  end
  def skater_name
    skater.name
  end
  delegate :nation, to: :skater
  delegate :start_date, to: :competition

  [:tss, :tes, :pcs, :deductions, :base_value].each do |key|
    define_method("short_#{key}".to_sym) do
      short.try(:send, key)
    end
    define_method("free_#{key}".to_sym) do
      free.try(:send, key)
    end
  end

  ## scopes
  scope :recent, ->{ joins(:competition).order("competitions.start_date desc") }
  scope :category, ->(cat) { where(category: cat) }

  def summary
    "  %s %2d %-35s (%6d)[%s] | %6.2f %2d / %2d" %
      [self.category.name, self.ranking.to_i, self.skater.name.truncate(35), self.skater.isu_number.to_i, self.skater.nation, self.points.to_f, self.short_ranking.to_i, self.free_ranking.to_i]
  end
end
