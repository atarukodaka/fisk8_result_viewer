require 'fisk8viewer/utils'

module Fisk8Viewer
  class Parser
    class CompetitionSummaryParser
      include Utils

      def parse_datetime(str)
        begin
          Time.zone ||= "UTC"
          Time.zone.parse(str)
        rescue ArgumentError
          raise "invalid date format"
        end
      end
      def parse_city_country(page)
        node = page.search("td.caption3").presence || page.xpath("//h3")
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
        rows = elem.xpath('ancestor::table[1]//tr')
        
      end
      def parse_time_schedule(page)
        ## time schdule
        #date_elem = page.xpath("//*[text()='Date']").first
        #rows = date_elem.xpath("../../tr")
        #rows = date_elem.xpath("ancestor::table//tr")
        #rows = page.xpath("//table[*[th[text()='Date']]]").xpath(".//tr")
        #rows = page.xpath("//table[.//*[text()='Date']]").xpath(".//tr")
        #binding.pry
        rows = get_time_schedule_rows(page)
        #binding.pry
        dt_str = ""
        time_schedule = []
        rows.each do |row|
          next if row.xpath("td").blank?
          if (t = row.xpath("td[1]").text.presence)
            dt_str = t
            next
          end
          tm_str = row.xpath("td[2]").text
          tm = parse_datetime("#{dt_str} #{tm_str}")
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
      def parse(url)
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
      ################
    end
  end  ## module
end
