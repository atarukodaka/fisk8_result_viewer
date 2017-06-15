class Skater < ApplicationRecord
  ## relations
  has_many :category_results
  has_many :scores
  has_many :elements, through: :scores
  has_many :components, through: :scores

  ## validations
  validates :nation, allow_nil: true, format: { with: /\A[A-Z][A-Z][A-Z]\Z/}
  validates :isu_number, allow_nil: true, numericality:  { only_integer: true }

  ## scopes
  scope :having_scores, ->{
    where(id: Score.select(:skater_id).group(:skater_id).having("count(skater_id)> ? ", 0))
  }
  scope :name_matches, ->(v){ where('skaters.name like ? ', "%#{v}%") }

  ## class methods
  class << self
    def find_by_isu_number_or_name(isu_number, name)
      (find_by(isu_number: isu_number) if isu_number.present?) ||
        (find_by(name: name))
    end
    def find_or_create_by_isu_number_or_name(isu_number, name)
      name = correct_name(name)
      find_by_isu_number_or_name(isu_number, name) || create do |skater|
        skater.isu_number = isu_number
        skater.name = name
        yield skater if block_given?
      end
    end
    def correct_name(skater_name)
      filename = Rails.root.join('config', 'skater_name_correction.yml')
      @_skater_corrections ||= YAML.load_file(filename)
      @_skater_corrections[skater_name] || skater_name
    end
  end  ## class << self
  
end ## class Skater
