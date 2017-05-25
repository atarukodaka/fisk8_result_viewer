class Score < ApplicationRecord
  after_initialize :set_default_values
  
  has_many :elements, dependent: :destroy
  has_many :components, dependent: :destroy

  belongs_to :competition
  belongs_to :skater
  belongs_to :category_result, required: false

  validates :sid, presence: true, uniqueness: true
  validates :nation, allow_nil: true, format: { with: /\A[A-Z][A-Z][A-Z]\Z/}  
  
  scope :recent, ->{
    order("date desc")
  }

=begin
  self.register_select_options_callback(:competition_name) do |key|
    Score.order("date desc").pluck(key).uniq.unshift(nil)
  end

  self.register_select_options_callback(:category) do |key|
    preset = [:MEN, :LADIES, :PAIRS, :"ICE DANCE",
              :"JUNIOR MEN", :"JUNIOR LADIES", :"JUNIOR PAIRS", :"JUNIOR ICE DANCE",]
    [nil, preset, pluck(key).uniq.sort.reject {|k| k.nil? || preset.include?(k.to_sym)}].flatten
  end

  self.register_select_options_callback(:segment) do |key|
    preset = [:"SHORT PROGRAM", :"FREE SKATING", :"SHORT DANCE", :"FREE DANCE"]
    [nil, preset, pluck(key).uniq.sort.reject {|k| k.nil? || preset.include?(k.to_sym)}].flatten    
  end
=end

  ################
  private
  def set_default_values
    self.sid ||= [self.competition.cid, self.category, self.segment, self.ranking].join("-")
  end
end

