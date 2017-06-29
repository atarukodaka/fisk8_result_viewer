
class Direction
  def initialize(data = nil)
    data ||= :asc
    @data = (data.to_sym == :desc) ? :desc : :asc
  end
  def current
    @data
  end
  def opposit
    (@data == :asc) ? :desc : :asc
  end
  def opposit!
    @data = opposit
  end
end

module ToDirection
  refine String do
    def to_direction
      Direction.new(self)
    end
  end
  refine NilClass do
    def to_direction
      Direction.new(self)
    end
  end
  refine Symbol do
    def to_direction
      Direction.new(self)
    end
  end
end

=begin
class NilClass
  include ToDirection
end

class String
  include ToDirection
end
    
class Symbol
  include ToDirection
end
=end
