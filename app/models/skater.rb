class Skater < ApplicationRecord
  alias_attribute :skater_name, :name

  class << self
    def find_or_create_by_name_or_isu_number(name:, isu_number:)
      corrected_name = SkaterNameCorrection.correct(name)
      skater = Skater.find_by(isu_number: isu_number) if isu_number.present?
      skater || Skater.find_or_create_by(name: corrected_name) do |sk|
        sk.isu_number = isu_number
        yield(sk) if block_given?
      end
    end
  end

  ## relations
  has_many :category_results, dependent: :nullify
  # belongs_to :category   ## reference
  belongs_to :category_type
  #has_many :grandprix_entries

  ## validations
  validates :nation, allow_nil: true, format: { with: /\A[A-Z][A-Z][A-Z]\Z/ }
  validates :isu_number, allow_nil: true, numericality: { only_integer: true }

  ## scopes
  scope :having_scores, lambda {
    where(id: Score.select(:skater_id).group(:skater_id).having('count(skater_id)> ? ', 0))
  }
  scope :name_matches, ->(v) { where('skaters.name like ? ', "%#{v}%") }

  ## virtual methods
  delegate :category_type_name, to: :category_type, allow_nil: true
end
