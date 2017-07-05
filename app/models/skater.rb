class Skater < ApplicationRecord
  ## relations
  has_many :category_results
  has_many :scores
  has_many :elements, through: :scores
  has_many :components, through: :scores

  ## validations
  validates :nation, allow_nil: true, format: { with: /\A[A-Z][A-Z][A-Z]\Z/}
  validates :isu_number, allow_nil: true, numericality:  { only_integer: true }

  ## entries
  def highest_score
    category_results.highest_score
  end
  def number_of_competitions_participated
    category_results.count
  end
  def number_of_gold_won
    category_results.where(ranking: 1).count
  end
  def highest_ranking
    category_results.highest_ranking
  end
  def most_valuable_element
    elements.order(:value).last.decorate.description
  end
  def most_valuable_components
    components.group(:number).maximum(:value).values.join('/')
  end
    
  ## scopes
  scope :having_scores, ->{
    where(id: Score.select(:skater_id).group(:skater_id).having("count(skater_id)> ? ", 0))
  }
  scope :name_matches, ->(v){ where('skaters.name like ? ', "%#{v}%") }

  ## class methods
  class << self
    def create_skaters
      parser = Parser::SkaterParser.new
      ActiveRecord::Base.transaction do
        parser.parse_skaters().each do |hash|
          Skater.find_or_create_by(isu_number: hash[:isu_number]) do |skater|
            logger.debug(skater)
            skater.update!(hash)   # TODO: if save failed
          end
        end
      end
    end
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
