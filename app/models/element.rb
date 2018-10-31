class Element < ApplicationRecord
  include ScoreVirtualAttributes

  alias_attribute :element_name, :name

  ## relations
  # has_many :element_judge_details, dependent: :destroy
  has_many :judge_details, as: :detailable, dependent: :destroy
  has_many :officials, through: :judge_details

  belongs_to :score

  ## scopes
  scope :recent, -> { joins(:score).order('scores.date desc') }

  ## callbacks
  before_save :set_element_type, :set_level

  alias_attribute :element_number, :number

  private

  # rubocop:disable all
  def icedance_elements(name)
    case name
    when /FO/, /FT/, /RF/, /EW/, /AW/, /WW/, /VW/, /OW/, /SW/, /RW/, /GW/, /KI/, /YP/, /QS/, /FS/, /PD/, /RH/, /CC/, /SS/, /TA/, /AT/, /TR/, /BL/, /MB/, /BL/, /BL/, /QS/, /CC/, /VW/
      [:pattern_dance, nil]
    when /[12]SS/, /1PD/, /PSt/, /R[12]Sq/
      [:pattern_dance, :element]

    when /MiSt/, /DiSt/, /CiSt/, /SeSt/
      [:step, nil]
    when /StaLi/, /SlLi/, /CuLi/, /RoLi/, /SeLi/, /ChLi/, /^Li/
      [:lift, nil]
    when /STw/, /ChTw/
      [:twizzle, nil]
    when /Sp/
      [:spin, nil]
    else
      [:unknown, nil]
    end
  end

  def set_element_type
    self[:element_type], self[:element_subtype] =
                         if score.category.name == 'ICE DANCE'
                           icedance_elements(name)
                         else
                           case name
                           when /St/
                             [:step, nil]
                           when /ChSq/
                             [:choreo, nil]
                           when /Tw/ # /[1-4]A?Tw/, /[1-4]LzTw/
                             [:lift, :twist]
                           #:twist_lift

                           when /Li/ # /[1-5][ABTSR]?Li/, /StaLi/, /SlLi/, /CuLi/, /RoLi/   # pair
                             [:lift, :pair]
                           when /Th/
                             [:jump, :throw]
                           #:throw_jump
                           when /Ds/, /PiF/
                             [:death_spiral, nil]

                           when /Sp/
                             case name
                             when /CoSp/
                               [:spin, :comb]
                             when /SSp/
                               [:spin, :sit]
                             when /CSp/
                               [:spin, :camel]
                             when /USp/
                               [:spin, :upright]
                             when /LSp/
                               [:spin, :layback]
                             when /ChSp/
                               [:spin, :choreo]
                             else
                               [:spin, nil]
                             end
                           when /^\d[AFST]/, /^\dL[oz]/, /^[AFST]/, /^L[oz]/
                             if name =~ /\+/ || name =~ /COMB/ || name =~ /REP/
                               [:jump, :comb]
                             else
                               [:jump, :solo]
                             end
                           else
                             [:unknown, nil]
                           end
                         end
    self
  end
  # rubocop:enable all

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
        1 # TODO: choreo for icedance ??
      else
        0
      end
    self
  end
end
