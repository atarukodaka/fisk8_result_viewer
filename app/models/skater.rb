class Skater < ApplicationRecord
  alias_attribute :skater_name, :name

  ## relations
  has_many :category_results, dependent: :nullify
  # belongs_to :category   ## reference
  belongs_to :category_type

  ## validations
  validates :nation, allow_nil: true, format: { with: /\A[A-Z][A-Z][A-Z]\Z/ }
  validates :isu_number, allow_nil: true, numericality: { only_integer: true }

  ## scopes
  scope :having_scores, -> {
    where(id: Score.select(:skater_id).group(:skater_id).having('count(skater_id)> ? ', 0))
  }
  scope :name_matches, ->(v) { where('skaters.name like ? ', "%#{v}%") }

  ## virtual methods
  delegate :category_type_name, to: :category_type, allow_nil: true
end
