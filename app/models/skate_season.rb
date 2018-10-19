class SkateSeason
  include Comparable
  attr_reader :start_date

  def initialize(date)
    tmp_date = 
      case date
      when String
        if date =~ /^(\d\d\d\d)\-\d\d$/  ||  ## 2016-17 format
           date =~ /^(\d\d\d\d)$/               ## 2016 format
          Date.new($1.to_i, 7, 1)
        else                                             ## parse as date string
          Date.parse(date)
        end
      when Integer
        Date.new(date, 7, 1)
      when Date
        date
      else
        raise
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

  def <=>(other)
    start_date <=> other.start_date
  end
end
