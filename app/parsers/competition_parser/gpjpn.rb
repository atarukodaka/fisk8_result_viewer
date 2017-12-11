module CompetitionParser
  class Gpjpn < IsuGeneric
    class SummaryParser  < IsuGeneric::SummaryParser
      def parse_name(_page)
        "ISU GP NHK Trophy 2017"
      end
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
        rows[0..-1].each do |row|
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
              panel_url: panel_url,
            }
          end
        end
        summary
      end
      def parse_time_schedule(page)
        Time.zone ||= "UTC"
        header_elem = page.xpath("//*[text()='Date']").first
        rows = header_elem.xpath("../../tr")
        rows.each do |row|
        end
                      
          [
           {
             time: Time.zone.parse("2017/11/11 12:45:00"),
             category: "ICE DANCE",
             segment: "SHORT DANCE",
           },
           {
             time: Time.zone.parse("2017/11/10 16:10:00"),
             category: "LADIES",
             segment: "SHORT PROGRAM",
           },
           {
             time: Time.zone.parse("2017/11/11 19:05:00"),
             category: "MEN",
             segment: "SHORT PROGRAM",
           },
           {
             time: Time.zone.parse("2017/11/10 14:20:00"),
             category: "PAIRS",
             segment: "SHORT PROGRAM",
           },
           {
             time: Time.zone.parse("2017/11/12 11:45:00"),
             category: "ICE DANCE",
             segment: "FREE DANCE",
           },
           {
             time: Time.zone.parse("2017/11/11 19:30:00"),
             category: "MEN",
             segment: "FREE SKATING",
           },
           {
             time: Time.zone.parse("2017/11/11 14:35:00"),
             category: "PAIRS",
             segment: "FREE SKATING",
           },
           {
             time: Time.zone.parse("2017/11/11 16:40:00"),
             category: "LADIES",
             segment: "FREE SKATING",
           },
          ]
      end
    end  ## class SummaryParser
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
