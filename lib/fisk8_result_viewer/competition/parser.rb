module Fisk8ResultViewer
  module Competition
    class Parser
      include Utils
      include Contracts
      
      # return true if mmddyyyy format
      Contract Array => Bool
      def mdy_date_format?(ary_datestr)
        dates = []
        ary_datestr.each do |datestr|
          datestr = trim(datestr)
          #next unless datestr =~ %r{^[0-9/.\-\s]+$}
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
      Contract String, KeywordArgs[mdy_format: Bool] => Time
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
          city.sub!(/ *$/, '') if city.present?
          [city, country]
        else
          [str, nil]
        end
      end
      def parse_summary_table(page)
        #category_elem = page.xpath("//*[text()='Category']").first
        #rows = category_elem.ancestors.xpath("table").first.xpath(".//tr")
        #rows = page.xpath("//table[.//*[text()='Category']]").xpath(".//tr")
        elem = page.xpath("//*[text()='Category']").first || raise
        rows = elem.xpath('ancestor::table[1]//tr')
        
        category = ""
        summary = []
        
        rows.each do |row|
          next if row.xpath("td").blank?
          
          if (c = row.xpath("td[1]").text.presence)
            category = trim(c).upcase.gsub(/^SENIOR /, '')
          end
          segment = trim(row.xpath("td[2]").text).upcase
          next if category.blank? && segment.blank?
          
          result_url = row.xpath("td[4]//a/@href").text
          score_url = row.xpath("td[5]//a/@href").text
          
          summary << {
            category: category,
            segment: segment,
            result_url: (result_url.present?) ? URI.join(@url, result_url).to_s: "",
            score_url: (score_url.present?) ? URI.join(@url, score_url).to_s : "",
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
          tm = tm + 2000.years if tm.year < 2000
          
          time_schedule << {
            time: tm,
            category: row.xpath("td[3]").text.upcase.gsub(/^SENIOR /, ''),
            segment: row.xpath("td[4]").text.upcase,
          }
        end
        time_schedule
      end
      def parse_name(page)
        page.title.strip
      end
      ################
      Contract String => Hash
      def parse_competition(url)
        @url = url
        page = get_url(url)
        return {} if page.nil?
        city, country = parse_city_country(page)

        {
          name: parse_name(page),
          site_url: url,
          city: city,
          country: country,
          result_summary: parse_summary_table(page),
          time_schedule: parse_time_schedule(page),
        }
      end
    end
  end  ## module
end