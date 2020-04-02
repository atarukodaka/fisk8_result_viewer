class CompetitionParser
  class TimeScheduleParser < Parser
    include CompetitionParser::Utils

    def get_timezone(page)
      page.xpath("//*[contains(text(), 'Local Time')]").text =~ / ([\+\-]\d\d:\d\d)/
      $1 =~ /([\+\-]\d\d)/
      utc_offset = $1.to_i

      ActiveSupport::TimeZone['Etc/GMT%+d' % [utc_offset * -1]]
    end

    def get_time_schedule_rows(page)
      find_table_rows(page, 'Date')   ##|| raise("time schedule table not found")
    end

    def parse(page, date_format: nil)
      rows = get_time_schedule_rows(page)
      return [] if rows.nil?

      dt_str = ''
      tz = get_timezone(page)
      opts = { timezone: tz }
      opts[:date_formats] = [date_format] if date_format
      data = rows.map do |row|
        next if row.xpath('td').blank?

        if (t = row.xpath('td[1]').text.presence)
          dt_str = t
          next
        end
        tm_str = row.xpath('td[2]').text
        dt_tm_str = "#{dt_str} #{tm_str}"

        {
          starting_time: DatetimeParser.parse(dt_tm_str, opts),
          category: normalize_category(row.xpath('td[3]').text),
          segment:  row.xpath('td[4]').text.squish.upcase.sub(/ \- .*$/, '')
        }
      end.compact

      validate_period(data)
      data
    end

    def validate_period(data)
      ## chk within 30days?
      accesptable_period = 30
      unless DatetimeParser.within_days?(data.map { |d| d[:starting_time] }, days: accesptable_period)
        data.each { |d| puts [d[:starting_time], d[:category], d[:segment]].join(', ') }
        puts('period over #{acceptable_period} days. correct ? (yes/no)')
        raise unless STDIN.gets.chomp =~ /yes/i
      end
    end
  end
end
