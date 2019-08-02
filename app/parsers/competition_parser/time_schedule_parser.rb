class CompetitionParser
  class TimeScheduleParser < Parser
    include CompetitionParser::Utils

    def get_timezone(page)
      page.xpath("//*[contains(text(), 'Local Time')]").text =~ / ([\+\-]\d\d:\d\d)/
      $1 =~ /([\+\-]\d\d)/
      utc_offset = $1.to_i

      'Etc/GMT%+d' % [utc_offset * -1]
    end

    def get_time_schedule_rows(page)
      elem = page.xpath("//table//tr//*[text()='Date']").first || raise
      elem.xpath('ancestor::table[1]//tr')
    end

    def parse(page, date_format: nil) ## TODO: date_format
      rows = find_table_rows(page, "Date") || raise("time schedule table not found")

      dt_str = ''
      timezone = get_timezone(page)
      data = rows.reject { |row| row.xpath('td').blank? }.map do |row|
        if (t = row.xpath('td[1]').text.presence)
          dt_str = t
          next
        end

        tm_str = row.xpath('td[2]').text
        dt_tm_str = "#{dt_str} #{tm_str}"

        tm = if date_format.present?
               Time.strptime(dt_tm_str, "#{date_format} %H:%M:%S")
             else
               dt_tm_str
             end.in_time_zone(ActiveSupport::TimeZone[timezone])
        tm += 2000.years if tm.year < 100 ## for ondrei nepela
        {
          starting_time: tm,
          category: normalize_category(row.xpath('td[3]').text),
          segment:  row.xpath('td[4]').text.squish.upcase.sub(/ \- .*$/, '')
        }
      end.compact

      ## check parsed date
      min_date = data.map { |d| d[:starting_time] }.min.to_date
      max_date = data.map { |d| d[:starting_time] }.max.to_date
      raise "date parsing error: #{min_date} - #{max_date}" if max_date - min_date > 30

      data
    end
  end
end
