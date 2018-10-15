class CompetitionParser
  module Extension
    class Wtt2017 < Gpjpn
      class SummaryTableParser < CompetitionParser::Extension::Gpjpn::SummaryTableParser
        def parse(page, base_url: '')
          data = super(page, base_url: base_url)

          ## no category results
          data.reject { |d| d[:type] == :category }.map do |item|
            item[:category] = "TEAM #{item[:category]}" if item[:category].present?
            item
          end
        end

        def header_element(page)
          page.xpath("//*[text()='Teams']").first
        end
      end

      ################
      def parse_name(_page)
        'ISU World Team Trophy 2017'
      end

      def parse_city_country(_page)
        %w[Tokyo JPN]
      end

      def parse_summary_table(page, base_url: nil)
        SummaryTableParser.new.parse(page, base_url: base_url)
      end

      ################
      # rubocop:disable all
      def parse_time_schedule(_page, date_format:)
        Time.zone ||= 'UTC'
        data = [
          {
            starting_time: Time.zone.parse('2017/04/20 15:15:00'),
            category: 'TEAM ICE DANCE',
            segment: 'SHORT DANCE',
          },
          {
            starting_time: Time.zone.parse('2017/04/20 16:35:00'),
            category: 'TEAM LADIES',
            segment: 'SHORT PROGRAM',
          },
          {
            starting_time: Time.zone.parse('2017/04/20 18:40:00'),
            category: 'TEAM MEN',
            segment: 'SHORT PROGRAM',
          },
          {
            starting_time: Time.zone.parse('2017/04/21 16:00:00'),
            category: 'TEAM PAIRS',
            segment: 'SHORT PROGRAM',
          },
          {
            starting_time: Time.zone.parse('2017/04/21 17:25:00'),
            category: 'TEAM ICE DANCE',
            segment: 'FREE DANCE',
          },
          {
            starting_time: Time.zone.parse('2017/04/21 19:00:00'),
            category: 'TEAM MEN',
            segment: 'FREE SKATING',
          },
          {
            starting_time: Time.zone.parse('2017/04/22 15:15:00'),
            category: 'TEAM PAIRS',
            segment: 'FREE SKATING',
          },

          {
            starting_time: Time.zone.parse('2017/04/22 16:50:00'),
            category: 'TEAM LADIES',
            segment: 'FREE SKATING',
          },
        ]
        data
      end
      # rubocop:enable all
    end
  end
end
