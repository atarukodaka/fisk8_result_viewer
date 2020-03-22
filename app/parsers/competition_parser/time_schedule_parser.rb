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
      #elem = page.xpath("//table//tr//*[text()='Date']").first || raise
      #elem.xpath('ancestor::table[1]//tr')
      find_table_rows(page, 'Date')   ##|| raise("time schedule table not found")
    end

    def parse(page)
      # rows = find_table_rows(page, "Date") || raise("time schedule table not found")
      rows = get_time_schedule_rows(page)
      return [] if rows.nil?

      dt_str = ''
      tz = get_timezone(page)

      data = rows.map do |row|
        next if row.xpath('td').blank?

        if (t = row.xpath('td[1]').text.presence)
          dt_str = t
          next
        end
        tm_str = row.xpath('td[2]').text
        dt_tm_str = "#{dt_str} #{tm_str}"

        {
          starting_time: dt_tm_str,
          category: normalize_category(row.xpath('td[3]').text),
          segment:  row.xpath('td[4]').text.squish.upcase.sub(/ \- .*$/, '')
        }
      end.compact

      [nil, '%d/%m/%Y', '%m/%d/%Y', '%d.%m.%Y', '%m.%d.%Y'].each do |md_format|
        #debug("** parse date by #{md_format}")
        invalid_format = false
        tmp_data = data.deep_dup
        tmp_data.each do |elem|
          begin
            tm = if md_format.nil?
                   elem[:starting_time].in_time_zone(tz)
                 else
                   Time.strptime(elem[:starting_time], "#{md_format} %H:%M:%S").in_time_zone(tz)
                 end
            tm += 2000.years if tm.year < 100 ## for ondrei nepela
            elem[:starting_time] = tm
          rescue ArgumentError
            invalid_format = true
            #debug("** invalid format #{md_format} on #{elem[:starting_time]}")
            break
          end
        end

        ## date range check
        next if invalid_format || tmp_data.empty?

        min_date = tmp_data.map { |d| d[:starting_time] }.min.to_date
        max_date = tmp_data.map { |d| d[:starting_time] }.max.to_date

        if max_date - min_date < 30  # looks okey
          data = tmp_data
          # debug("** time parse okey")
          break
        else
          # debug("** looks strange: try other format")
        end
      end
      data
    end
  end
end
