module Fisk8Viewer
  module Parsers
    class WTT_2017 < ISU_Generic
      class CompetitionSummaryParser < ISU_Generic::CompetitionSummaryParser
        def parse_name(page)
          "ISU World Team Trophy 2017"
        end
        def parse_city_country(page)
          ["Tokyo", "JPN"]
        end

        def parse_summary_table(page)
          header_elem = page.xpath("//*[text()='Teams']").first
          rows = header_elem.xpath("../../tr")
          category = ""
          segment = ""
          summary = []
          entry_url = ""
          rows.each do |row|
            next if row.xpath("td").blank?

            if row.xpath("td[2]").text == 'Entries'
              category = row.xpath("td[1]").text.upcase
              ## NOTE: WTT2017 doesnt provide category result, so we use entry list as a result (to get isu number for skaters)
              entry_url = URI.join(@url,row.xpath("td[2]/a/@href").text).to_s
              summary << {
                category: category,
                segment: '',
                result_url: entry_url,
                score_url: '',
              }
            elsif row.xpath("td").count == 2
              segment = row.xpath("td[1]").text.upcase
            elsif row.xpath("td[1]").text == "Judges Score (pdf)"
              score_url = URI.join(@url, row.xpath("td[1]/a/@href").text).to_s
              summary << {
                category: category, 
                segment: segment,
                result_url: "",
                score_url: score_url,
              }
            end
          end
          summary
        end
        # rubocop:disable all
        def parse_time_schedule(page)
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

      ################################################################
      class CategoryResultParser < ISU_Generic::CategoryResultParser
        def get_rows(page)
          page.xpath("//table[1]/tr")
        end
=begin
        def get_category(page)
          text = page.xpath("//p[1]").text
          text.sub(/ \- Entry/, '').upcase
        end
=end
        def parse_skater_name(v)
          v.xpath('a/text()').map(&:text).join(' / ').gsub(/\u00a0/, ' ')
        end
        def parse_nation(v)
          v.gsub(/\u00a0/, '')
        end
        def parse(url)
          page = get_url(url)
          page.encoding = 'iso-8859-1'

          page.xpath("//table[1]/tr")[1..-1].map do |row|
            {
              ranking: row.xpath("td[1]").text.to_i,
              skater_name: parse_skater_name(row.xpath("td[2]")),
              nation: parse_nation(row.xpath("td[3]").text),
              isu_number: (row.xpath("td[2]/a/@href").text =~ /([0-9]+)\.htm$/) ? $1.to_i : nil,
            }
          end
        end
      end
      ## register
      Fisk8Viewer::Parsers.register(:wtt_2017, self)
    end ## class
  end
end

