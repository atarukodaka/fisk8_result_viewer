class SkateSeason
  include Comparable
  attr_reader :start_date

  def initialize(date)
    tmp_date =
      case date
      when String
        if date =~ /^(\d\d\d\d)\-\d\d$/ || ## 2016-17 format
           date =~ /^(\d\d\d\d)$/               ## 2016 format
          Date.new($1.to_i, 7, 1)
        else                                             ## parse as date string
          Date.parse(date)
        end
      when Integer
        Date.new(date, 7, 1)
      when Date, Time, ActiveSupport::TimeWithZone
        date
      when NilClass
        Date.today
      else
        raise "#{date.class} not supported"
      end

    year, month = tmp_date.year, tmp_date.month
    year -= 1 if month < 7
    @start_date = Date.new(year, 7, 1)
  end

  def season
    year = start_date.year
    '%04d-%02d' % [year, (year + 1) % 100]
  end
  alias to_s season

  def between?(from, to)
    flag = true
    if from.present?
      season_from = SkateSeason.new(from)
      flag = (season_from <= self)
    end

    if flag && to.present?
      season_to = SkateSeason.new(to)
      flag = (self <= season_to)
    end
    flag
  end

  ## operators
  def +(other)
    case other
    when Integer
      SkateSeason.new(self.start_date.year + other)
    when SkateSeason
      self.start_date.year + other.start_date.year
    end
  end

  def -(other)
    case other
    when Integer
      SkateSeason.new(self.start_date.year - other)
    when SkateSeason
      self.start_date.year - other.start_date.year
    end
  end

=begin
  def ==(other)
    case other
    when SkateSeason
      super.==(other)
    else
      super.==(SkateSeason.new(other))
    end
  end
=end
  def <=>(other)
    other_season = (other.class == SkateSeason) ? other : SkateSeason.new(other)
    start_date <=> other_season.start_date
  end
end
