class CompetitionParser
  class SummaryParser < Parser
    def parse(site_url, date_format:)
      page = get_url(site_url) || return

      debug(" -- parse summary: #{site_url}")
      city, country = parse_city_country(page)

      competition = {
        name:     parse_name(page),
        site_url: site_url,
        city:     city,
        country:  country,
      }
      result_summary = parse_summary_table(page, url: site_url)
      time_schedule =  parse_time_schedule(page, date_format: date_format)

      competition[:category_results] = []
      competition[:segment_results] = []
      result_summary.each do |item|
        if item[:segment].blank?
          competition[:category_results] << item.slice(:category, :result_url)
        else
          competition[:segment_results] << item.slice(:category, :segment, :panel_url, :result_url, :score_url)
        end
      end
      competition[:time_schedule] = time_schedule
      competition
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

    def parse_summary_table(page, url: '')
      elem = page.xpath("//*[text()='Category']").first || raise
      rows = elem.xpath('ancestor::table[1]//tr')
      category = ''
      summary = []

      rows.each do |row|
        next if row.xpath('td').blank?

        if (c = row.xpath('td[1]').text.presence)
          category = normalize_category(c)
        end
        segment = row.xpath('td[2]').text.squish.upcase

        next if category.blank? && segment.blank?
        next if segment.blank? && (row.xpath('td[4]').text =~ /result/i).nil? # TODO: ??

        panel_url = row.xpath('td[3]//a/@href').text
        result_url = row.xpath('td[4]//a/@href').text
        score_url = row.xpath('td[5]//a/@href').text
        summary << {
          category:   category,
          segment:    segment,
          panel_url:  (panel_url.present?) ? File.join(url, panel_url).to_s : '',
          result_url: (result_url.present?) ? File.join(url, result_url).to_s : '',
          score_url:  (score_url.present?) ? File.join(url, score_url).to_s : '',
        }
      end
      summary
    end

    ################
    def get_timezone(page)
      page.xpath("//*[contains(text(), 'Local Time')]").text =~ / ([\+\-]\d\d:\d\d)/
      # local_tz = $1 || '+00:00'
      $1 =~ /([\+\-]\d\d)/
      utc_offset = $1.to_i

      'Etc/GMT%+d' % [utc_offset * -1]
    end

    def get_time_schedule_rows(page)
      # page.xpath("//table[*[th[text()='Date']]]").xpath(".//tr")
      elem = page.xpath("//table//tr//*[text()='Date']").first || raise
      elem.xpath('ancestor::table[1]//tr')
    end

    def parse_time_schedule(page, date_format:)
      ## time schedule
      rows = get_time_schedule_rows(page)
      dt_str = ''
      time_schedule = []
      timezone = get_timezone(page)

      rows.each do |row|
        next if row.xpath('td').blank?

        if (t = row.xpath('td[1]').text.presence)
          dt_str = t
          next
        end

        tm_str = row.xpath('td[2]').text
        dt_tm_str = "#{dt_str} #{tm_str}"
        # dt_tm_str += " #{local_tz}" if tz == "UTC"
        # tz = "Etc/GMT#{local_tz_hour.to_i }"

        tm =
          if date_format.present?
            Time.strptime(dt_tm_str, "#{date_format} %H:%M:%S")
          else
            dt_tm_str
          end.in_time_zone(ActiveSupport::TimeZone[timezone])
        # next if tm.nil?
        tm += 2000.years if tm.year < 100 ## for ondrei nepela

        time_schedule << {
          starting_time:     tm,
          category: normalize_category(row.xpath('td[3]').text),
          segment:  row.xpath('td[4]').text.squish.upcase,
        }
      end
      time_schedule
    end

    def parse_name(page)
      page.title.strip
    end

    ###
    private

    def normalize_category(category)
      category.squish.upcase.gsub(/^PAIR SKATING$/, 'PAIRS')
        .gsub(/^SENIOR /, '').gsub(/ SINGLE SKATING/, '').gsub(/ SKATING/, '')
    end
  end
end ## module
