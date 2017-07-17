class Parser
  class CompetitionParser
    include Utils

    def parse(url)
      page = get_url(url) || return

      city, country = parse_city_country(page)
      competition = {
        name: parse_name(page),
        site_url: url,
        city: city,
        country: country,
      }
      result_summary = parse_summary_table(page, url: url)
      time_schedule =  parse_time_schedule(page)

      competition[:categories] = {}
      competition[:segments] = Hash.new { |h,k| h[k] = {} }
      
      result_summary.each do |hash|
        category, segment = hash[:category], hash[:segment]
        cat_item = competition[:categories][category] ||= {}

        if hash[:segment].blank?
          cat_item[:result_url] = hash[:result_url]
        else
          seg_item = competition[:segments][category][segment] = {}
          seg_item[:score_url] = hash[:score_url]
          seg_item[:date] = time_schedule.select {|item| item[:category] == category && item[:segment] == segment}.first.try(:[], :time)
        end
      end
      competition[:start_date] = time_schedule.map {|d| d[:time]}.min
      competition[:end_date] = time_schedule.map {|d| d[:time]}.max

      year, month = competition[:start_date].year, competition[:start_date].month
      year -= 1 if month <= 6
      competition[:season] = "%04d-%02d" % [year, (year+1) % 100]
      
      competition
    end
    ################################################################
    protected
    # return true if mmddyyyy format

    def mdy_date_format?(ary_datestr)
      dates = []
      ary_datestr.each do |datestr|
        datestr.squish!
        next if datestr =~ /^[A-Za-z\s]+$/
        begin
          Time.zone ||= "UTC"
          dates << Time.zone.parse(datestr)
        rescue ArgumentError
          return true
        end
      end
      raise if dates.empty?
      return (dates.max - dates.min > 3600 * 24 * 10) ? true : false
    end
    def parse_datetime(str, mdy_format: false)
      begin
        Time.zone ||= "UTC"
        if mdy_format
          dt_str, tm_str = str.split(/ /)
          m, d, y = dt_str.split(/[,\/]/)
          dt_str = "%s/%s/%s" % [d, m, y]
          Time.zone.parse("#{dt_str} #{tm_str}")
        else
          Time.zone.parse(str)
        end
      rescue ArgumentError
        raise "invalid date format"
      end
    end
    
    def parse_city_country(page)
      node = page.search("td.caption3").presence || page.xpath("//h3") || raise
      str = (node.present?) ? node.first.text.strip : ""
      if str =~ %r{^(.*) *[,/] ([A-Z][A-Z][A-Z]) *$};
        city, country = $1, $2
        if city.present?
          city.sub!(/ *$/, '')
          city.sub!(/,.*$/, '')
          city.sub!(/ *\(.*\)$/, '')
          city.sub!(/ *\/.*$/, '')
        end
        [city, country]
      else
        [str, nil]  ## to be set in competition.update
      end
    end
    def parse_summary_table(page, url: "")
      elem = page.xpath("//*[text()='Category']").first || raise
      rows = elem.xpath('ancestor::table[1]//tr')
      
      category = ""
      summary = []
      
      rows.each do |row|
        next if row.xpath("td").blank?
        
        if (c = row.xpath("td[1]").text.presence)
          category = c.squish.upcase.gsub(/^SENIOR /, '')
        end
        #segment = trim(row.xpath("td[2]").text).upcase
        segment = row.xpath("td[2]").text.squish.upcase

        next if category.blank? && segment.blank?
        next if (segment.blank?) && ((row.xpath("td[4]").text =~ /result/i ) == nil) # TODO
          
        result_url = row.xpath("td[4]//a/@href").text
        score_url = row.xpath("td[5]//a/@href").text
        
        summary << {
          category: category,
          segment: segment,
          result_url: (result_url.present?) ? URI.join(url, result_url).to_s: "",
          score_url: (score_url.present?) ? URI.join(url, score_url).to_s : "",
        }
      end
      summary
    end
    def get_time_schedule_rows(page)
      #page.xpath("//table[*[th[text()='Date']]]").xpath(".//tr")
      elem = page.xpath("//table//tr//*[text()='Date']").first || raise
      elem.xpath('ancestor::table[1]//tr')
    end
    def parse_time_schedule(page)
      ## time schdule
      rows = get_time_schedule_rows(page)
      dt_str = ""
      time_schedule = []

      mdy_format = mdy_date_format?(rows.xpath(".//td[1]").map(&:text).reject {|v| v.blank? })
      rows.each do |row|
        next if row.xpath("td").blank?
        if (t = row.xpath("td[1]").text.presence)
          dt_str = t
          next
        end
        tm_str = row.xpath("td[2]").text
        tm = parse_datetime("#{dt_str} #{tm_str}", mdy_format: mdy_format)
        next if tm.nil?
        tm = tm + 2000.years if tm.year < 100
        
        time_schedule << {
          time: tm,
          category: row.xpath("td[3]").text.squish.upcase.gsub(/^SENIOR /, ''),
          segment: row.xpath("td[4]").text.squish.upcase,
        }
      end
      time_schedule
    end
    def parse_name(page)
      page.title.strip
    end
  end
end  ## module
