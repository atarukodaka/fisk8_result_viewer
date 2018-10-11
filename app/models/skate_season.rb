class SkateSeason
  include Comparable

  attr_reader :date

  def initialize(date)
    @date =
      if date.class == String
        if date =~ /^(\d\d\d\d)\-(\d\d)$/
          Date.new($1.to_i, 7, 1)
        else
          Date.parse(date)                ## TODO: rescue parse error
        end
      else
        date
      end
  end

  def season
    @season ||= '%04d-%02d' % [year, (year + 1) % 100]
  end

  def to_s
    season
  end

  def year
    y = @date.year
    y -= 1 if @date.month <= 6
    y
  end

  def start_date
    @start_date ||= Date.new(@date.year, 7, 1)
  end

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
    #      (season_from <= self) && (self <= season_to)
  end

  def <=>(other)
    start_date <=> other.start_date
  end
end
