module CompetitionParser
  class SummaryParser < Parser
    class << self
      def incorporate(parser_type)
        return self if parser_type.nil?

        prepended_class = [self.to_s, 'Extension', parser_type.to_s.camelize].join('::').constantize
        self.dup.prepend(prepended_class)
      end
    end
    ################
    def parse(site_url, date_format: nil)
      page = get_url(site_url) || return

      debug(" -- parse summary: #{site_url}")
      city, country = parse_city_country(page)

      results = parse_summary_table(page, url: site_url)
      summary = CompetitionParser::SummaryParser::Summary.new(
        name:     parse_name(page),
        site_url: site_url,
        city:     city,
        country:  country,
        category_results: results[:category_results],
        segment_results: results[:segment_results]
      )
      ## set starting_time for each segments
      time_schedule = parse_time_schedule(page, date_format: date_format)
      summary[:segment_results].each do |result|
        elem = time_schedule.select { |d|
          d[:category] == result[:category] &&
            d[:segment] == result[:segment]
        }.first
        result[:starting_time] = elem[:starting_time] if elem
      end
      summary
    end

    ################
    def parse_city_country(page)
      node = page.search('td.caption3').presence || page.xpath('//h3') || raise
      str = (node.present?) ? node.first.text.strip : ''
      if str =~ %r{^(.*) *[,/] ([A-Z][A-Z][A-Z]) *$}
        city, country = $1, $2
        city = city.to_s.sub(/ *$/, '').sub(/,.*$/, '').sub(/ *\(.*\)$/, '').sub!(/ *\/.*$/, '')
        [city, country]
      else
        [str, nil] ## to be set in competition.update()
      end
    end

    def parse_url_by_string(row, search_string, base_url: '')
      a_elem = nil
      Array(search_string).each do |string|
        xpath_normal = "td//a[contains(text(), '#{string}')]"
        xpath_csfin = "td//a[*[contains(text(), '#{string}')]]"
        if elem = row.xpath(" #{xpath_normal} | #{xpath_csfin} ").first
          a_elem = elem
          break
        end
      end
      (a_elem) ? File.join(base_url, a_elem.attributes['href'].value) : nil
    end
    
    def parse_url_by_column(row, column_number, base_url: '')
      File.join(base_url, row.xpath("td[#{column_number}]//a/@href").text)
    end
    def parse_summary_table(page, url: '')
      elem = page.xpath("//*[text()='Category']").first || raise
      rows = elem.xpath('ancestor::table[1]//tr')
      category = ''
      data = { category_results: [], segment_results: [] }

      rows.reject { |r| r.xpath('td').blank? }.each do |row|
        if (c = row.xpath('td[1]').text.presence)
          category = normalize_category(c)
        end
        segment = row.xpath('td[2]').text.squish.upcase
        next if (category.blank? && segment.blank?) ||
                row.xpath('td[3]').text.blank?  || row.xpath("td[4]").text =~ /cancelled/

        if segment.blank?   ## category section
          data[:category_results] << {
            category: category,
            result_url: parse_url_by_string(row, 'Result', base_url: url)
          }
        else    ## segment section
          data[:segment_results] << {
            category: category,
            segment: segment,
            panel_url: parse_url_by_column(row, 3, base_url: url),
            result_url: result_url = parse_url_by_column(row, 4, base_url: url),
            score_url: parse_url_by_column(row, 5, base_url: url)
          } 
        end
      end
      data
    end

    ################
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

    def parse_time_schedule(page, date_format:)
      ## time schedule
      rows = get_time_schedule_rows(page)
      dt_str = ''
      timezone = get_timezone(page)
      data = rows.map do |row|
        next if row.xpath('td').blank?

        if (t = row.xpath('td[1]').text.presence)
          dt_str = t
          next
        end

        tm_str = row.xpath('td[2]').text
        dt_tm_str = "#{dt_str} #{tm_str}"

        tm =
          if date_format.present?
            Time.strptime(dt_tm_str, "#{date_format} %H:%M:%S")
          else
            dt_tm_str
          end.in_time_zone(ActiveSupport::TimeZone[timezone])
        tm += 2000.years if tm.year < 100 ## for ondrei nepela

        {
          starting_time:     tm,
          category: normalize_category(row.xpath('td[3]').text),
          segment:  row.xpath('td[4]').text.squish.upcase
        }
      end
      # TimeSchedule.new(data.compact)
      data.compact
    end

    def parse_name(page)
      page.title.strip
    end

    private

    def normalize_category(category)
      category.squish.upcase.gsub(/^PAIR SKATING$/, 'PAIRS')
        .gsub(/^SENIOR /, '').gsub(/ SINGLE SKATING/, '').gsub(/ SKATING/, '')
    end
  end
end ## module
