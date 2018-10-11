module CompetitionParser
  class SummaryParser
    module Extension
      module Wtt2017
        def parse_name(_page)
          'ISU World Team Trophy 2017'
        end

        def parse_city_country(_page)
          %w[Tokyo JPN]
        end

        # rubocop:disable all
        def parse_summary_table(page, url: '')
          header_elem = page.xpath("//*[text()='Teams']").first
          rows = header_elem.xpath('../../tr')
          category = ''
          segment = ''
          summary = []
          # entry_url = ''
          panel_url = ''
          segment_result_url = ''

          rows[1..-1].each do |row|
            next if row.xpath('td').blank?

            if row.xpath('td[2]').text == 'Entries'
              category = row.xpath('td[1]').text.upcase
              ## NOTE: WTT2017 doesnt provide category result,
              ## so we use entry list as a result (to get isu number for skaters)

              # entry_url = URI.join(url,row.xpath("td[2]/a/@href").text).to_s
              summary << {
                category:   "TEAM #{category}",
                segment:    '',
                result_url: '',
                score_url:  '',
              }
            elsif row.xpath('td').count == 2
              segment = row.xpath('td[1]').text.upcase
              panel_url = URI.join(url, row.xpath('td[2]/a/@href').text).to_s
            elsif row.xpath('td[1]').text == 'Starting Order/Detailed Classification'
              segment_result_url = URI.join(url, row.xpath('td[1]/a/@href').text).to_s
            elsif row.xpath('td[1]').text == 'Judges Score (pdf)'
              score_url = URI.join(url, row.xpath('td[1]/a/@href').text).to_s
              summary << {
                category:   "TEAM #{category}",
                segment:    segment,
                result_url: segment_result_url,
                score_url:  score_url,
                panel_url:  panel_url,
              }
            end
          end
          summary
        end
        # rubocop:disable all
        def parse_time_schedule(_page, date_format:)
          Time.zone ||= "UTC"
          data = [
           {
             starting_time: Time.zone.parse("2017/04/20 15:15:00"),
             category: "TEAM ICE DANCE",
             segment: "SHORT DANCE",
           },
           {
             starting_time: Time.zone.parse("2017/04/20 16:35:00"),
             category: "TEAM LADIES",
             segment: "SHORT PROGRAM",
           },
           {
             starting_time: Time.zone.parse("2017/04/20 18:40:00"),
             category: "TEAM MEN",
             segment: "SHORT PROGRAM",
           },
           {
             starting_time: Time.zone.parse("2017/04/21 16:00:00"),
             category: "TEAM PAIRS",
             segment: "SHORT PROGRAM",
           },
           {
             starting_time: Time.zone.parse("2017/04/21 17:25:00"),
             category: "TEAM ICE DANCE",
             segment: "FREE DANCE",
           },
           {
             starting_time: Time.zone.parse("2017/04/21 19:00:00"),
             category: "TEAM MEN",
             segment: "FREE SKATING",
           },
           {
             starting_time: Time.zone.parse("2017/04/22 15:15:00"),
             category: "TEAM PAIRS",
             segment: "FREE SKATING",
           },

           {
             starting_time: Time.zone.parse("2017/04/22 16:50:00"),
             category: "TEAM LADIES",
             segment: "FREE SKATING",
           },
          ]
          TimeSchedule.new(data)
        end
        # rubocop:enable all
      end ##
    end
  end
end
