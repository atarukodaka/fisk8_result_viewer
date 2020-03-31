class DatetimeParser
  def self.parse(dt_tm_str, timezone: 'UTC', date_formats: nil)
    tm = nil
    date_formats ||= ['%d/%m/%Y', '%d.%m.%Y', '%m/%d/%Y', '%m.%d.%Y']

    date_formats.each do |date_format|
      begin
        tm = Time.strptime(dt_tm_str, "#{date_format} %H:%M:%S")
        break
      rescue ArgumentError
      end
    end
    tm ||= Time.parse(dt_tm_str)

    if tm.year < 100
      tm += (tm.year >= 69) ? 1900.years : 2000.years
    end
    tm.in_time_zone(timezone)
  end ## parse()

  def self.within_days?(ar, days: 30)
    ar.max.to_date - ar.min.to_date <= days
  end
end
