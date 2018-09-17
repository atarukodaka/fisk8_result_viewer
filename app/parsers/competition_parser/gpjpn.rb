class CompetitionParser
  class Gpjpn < IsuGeneric
    class SummaryParser  < IsuGeneric::SummaryParser
      def parse_city_country(_page)
        ['', "JPN"]
      end

      def parse_summary_table(page, url: "")
        header_elem = page.xpath("//*[text()='Men']").first
        rows = header_elem.xpath("../../tr")
        category = ""
        segment = ""
        summary = []
        entry_url = ""
        panel_url = ""
        segment_result_url = ""
        #rows[0..-1].each do |row|
        rows.each do |row|
          next if row.xpath("td").blank?

          if row.xpath("td[2]").text == 'Entries'
            category = row.xpath("td[1]").text.upcase
            result_url = URI.join(url,row.xpath("td[3]/a/@href").text).to_s
            summary << {
              category: category,
              segment: '',
              result_url: result_url,
              score_url: '',
            }
          elsif row.xpath("td").count == 2
            segment = row.xpath("td[1]").text.upcase
            panel_url = URI.join(url, row.xpath("td[2]/a/@href").text).to_s
          elsif row.xpath("td[1]").text == "Starting Order/Detailed Classification"
            segment_result_url = URI.join(url, row.xpath("td[1]/a/@href").text).to_s
          elsif row.xpath("td[1]").text == "Judges Score (pdf)"
            score_url = URI.join(url, row.xpath("td[1]/a/@href").text).to_s
            summary << {
              category: category, 
              segment: segment,
              result_url: segment_result_url,
              score_url: score_url,
#              panel_url: panel_url,
            }
          end
        end
        summary
      end
      def parse_time_schedule(page, date_format: "")
        Time.zone ||= "UTC"
        header_elem = page.xpath("//*[text()='Date']").first
        table = header_elem.xpath("../..")

        i = 1
        bHeader = true
        summary = []
        date = nil
        time = nil
        category = ""
        segment = ""
        timezone = "Asia/Tokyo"
        
        table.children.each do |elem|
          case elem.name
          when "text"
            next
          when "td"
            case i
            when 1
              date = elem.text
            when 2
              time = elem.text
            when 3
              category = elem.text.upcase
            when 4
              segment = elem.text.upcase
              summary << {
                category: category,
                segment: segment,
                time: "#{date} #{time}".in_time_zone(timezone),
              }
            end
            if i == 4
              i = 1
            else
              i += 1
            end
          when "tr"
            if bHeader  # skip if header
              bHeader = false
              next
            end
            summary << {
              category: elem.xpath("td[2]").text.upcase,
              segment: elem.xpath("td[3]").text.upcase,
              time: "#{date} #{elem.xpath("td[1]").text}".in_time_zone(timezone),
            }
          end
        end
        summary
      end
    end  ## class SummaryParser
  end ## class Gpjpn
end
