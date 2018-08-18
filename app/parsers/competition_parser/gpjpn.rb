module CompetitionParser
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
          elsif row.xpath("td[1]").text == "Judges Score (pdf)"
            score_url = URI.join(url, row.xpath("td[1]/a/@href").text).to_s
            summary << {
              category: category, 
              segment: segment,
              result_url: "",
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
                time: "#{date} #{time}".in_time_zone("Asia/Tokyo"),
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
              time: Time.zone.parse("#{date} #{elem.xpath("td[1]").text}"),
            }
          end
        end
        summary
      end
    end  ## class SummaryParser

    ################
    class ResultParser < IsuGeneric::ResultParser
      def get_rows(page)
        fpl = page.xpath("//td[contains(text(), 'PL')]")
        return [] if fpl.blank?
        
        fpl.first.xpath("../../tr")
      end
      def get_column_numbers(_)
        {ranking: 0, skater_name: 1, nation: 2, short_ranking: 3, free_ranking: 4, points: 5,}
      end
    end ## class ResultParser
  end ## class Gpjpn
end
