class Element < ApplicationRecord
  before_save :set_element_type
  
  ## relations
  belongs_to :score

  def score_name
    score.name
  end
  def competition_name
    score.competition.name
  end
  def category
    score.category
  end
  def segment
    score.segment
  end
  def date
    score.competition.start_date
  end
  def season
    score.competition.season
  end
  def ranking
    score.ranking
  end
  def skater_name
    score.skater.name
  end
  def nation
    score.skater.nation
  end

  ## scopes
  scope :recent, ->{ joins(:score).order("scores.date desc") }

  
  private
  def set_element_type
    self[:element_type] = 
      if score.category == "ICE DANCE"
        case name
        when /FO/, /FT/, /RF/, /EW/, /AW/, /WW/, /VW/, /OW/, /SW/, /RW/, /GW/, /KI/, /YP/, /QS/, /FS/, /PD/, /RH/, /CC/, /SS/, /TA/, /AT/, /TR/, /BL/, /MB/, /BL/, /BL/, /QS/, /CC/, /VW/
          :pattern_dance
        when /[12]SS/, /1PD/, /PSt/, /R[12]Sq/
          :pattern_dance_element

        when /MiSt/, /DiSt/, /CiSt/, /SeSt/
          :step
        when /StaLi/, /SlLi/, /CuLi/, /RoLi/, /SeLi/, /ChLi/, /^Li/
          :lift
        when /STw/, /ChTw/
          :twizzle
        when /Sp/
          :spin
        else
          :unknown
        end
      else
        case name
        when /St/, /ChSq/
          :step
        when /Tw/ # /[1-4]A?Tw/, /[1-4]LzTw/
          :twist_lift
        when /Li/  # /[1-5][ABTSR]?Li/, /StaLi/, /SlLi/, /CuLi/, /RoLi/   # pair
          :lift
        when /Th/
          :throw_jump
        when /Ds/, /PiF/
          :death_spiral

        when /Sp/
          :spin
        when /^\d[AFST]/, /^\dL[oz]/, /^[AFST]/, /^L[oz]/
          :jump
        else
          :unknown
        end
      end
    self
  end
end
