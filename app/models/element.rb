class Element < ApplicationRecord
  include ScoreVirtualAttributes
  
  ## relations
  #has_many :element_judge_details, dependent: :destroy
  belongs_to :score

  ## scopes
  scope :recent, ->{ joins(:score).order("scores.date desc") }

  ## callbacks
  before_save :set_element_type, :set_level
  
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
        when /St/
          :step
        when /ChSq/
          :choreo
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
  def set_level
    self.level =
      case element_type.to_sym
      when :spin
        tmp = name
        tmp.sub!(/\*$/, '')
        tmp.sub!(/[Vv][12]?$/, '')
        tmp.sub!(/Sp[23]p/, 'Sp')
        tmp =~ /Sp([B1-4])/
        $1.to_i
      when :step
        name =~ /([B1-4])*$/
        $1.to_i
      when :choreo
        1  # TODO: choreo for icedance ??
      else
        0
      end
    self
  end
end
