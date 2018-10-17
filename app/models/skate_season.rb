class SkateSeason
  include Comparable
  attr_reader :start_date

  def initialize(date)
    tmp_date =
      if date.class == String
        if date =~ /^(\d\d\d\d)\-(\d\d)$/   ## 2016-17 format
          Date.new($1.to_i, 7, 1)
        else
          Date.parse(date)                ## TODO: rescue parse error
        end
      else
        date
      end
    year, month = tmp_date.year, tmp_date.month
    year -= 1 if month < 7
    @start_date = Date.new(year, 7, 1)
  end

  def season
    year = start_date.year
    '%04d-%02d' % [year, (year + 1) % 100]
  end
  alias_method :to_s, :season

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
