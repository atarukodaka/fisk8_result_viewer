module CompetitionParser
  class Wtt2017 < IsuGeneric
    class SummaryParser < IsuGeneric::SummaryParser
      def parse_name(_page)
        "ISU World Team Trophy 2017"
      end
      def parse_city_country(_page)
        ["Tokyo", "JPN"]
      end

      def parse_summary_table(page, url: "")
        header_elem = page.xpath("//*[text()='Teams']").first
        rows = header_elem.xpath("../../tr")
        category = ""
        segment = ""
        summary = []
        entry_url = ""
        segment_result_url = ""

        rows[1..-1].each do |row|
          next if row.xpath("td").blank?

          if row.xpath("td[2]").text == 'Entries'
            category = row.xpath("td[1]").text.upcase
            ## NOTE: WTT2017 doesnt provide category result, so we use entry list as a result (to get isu number for skaters)
            #entry_url = URI.join(url,row.xpath("td[2]/a/@href").text).to_s
            summary << {
              category: category,
              segment: '',
              result_url: '',
              score_url: '',
            }
          elsif row.xpath("td").count == 2
            segment = row.xpath("td[1]").text.upcase
          elsif row.xpath("td[1]").text == "Starting Order/Detailed Classification"
            segment_result_url = URI.join(url, row.xpath("td[1]/a/@href").text).to_s            
          elsif row.xpath("td[1]").text == "Judges Score (pdf)"
            score_url = URI.join(url, row.xpath("td[1]/a/@href").text).to_s
            summary << {
              category: category, 
              segment: segment,
              result_url: segment_result_url,
              score_url: score_url,
            }
          end
        end
        summary
      end
      # rubocop:disable all
      def parse_time_schedule(_page, date_format:)
        Time.zone ||= "UTC"
        [
         {
           time: Time.zone.parse("2017/04/20 15:15:00"),
           category: "ICE DANCE",
           segment: "SHORT DANCE",
         },
         {
           time: Time.zone.parse("2017/04/20 16:35:00"),
           category: "LADIES",
           segment: "SHORT PROGRAM",
         },
         {
           time: Time.zone.parse("2017/04/20 18:40:00"),
           category: "MEN",
           segment: "SHORT PROGRAM",
         },
         {
           time: Time.zone.parse("2017/04/21 16:00:00"),
           category: "PAIRS",
           segment: "SHORT PROGRAM",
         },
         {
           time: Time.zone.parse("2017/04/21 17:25:00"),
           category: "ICE DANCE",
           segment: "FREE DANCE",
         },
         {
           time: Time.zone.parse("2017/04/21 19:00:00"),
           category: "MEN",
           segment: "FREE SKATING",
         },
         {
           time: Time.zone.parse("2017/04/22 15:15:00"),
           category: "PAIRS",
           segment: "FREE SKATING",
         },

         {
           time: Time.zone.parse("2017/04/22 16:50:00"),
           category: "LADIES",
           segment: "FREE SKATING",
         },
        ]
      end
      # rubocop:enable all
    end  ##
  end ## class Wtt2017
end

