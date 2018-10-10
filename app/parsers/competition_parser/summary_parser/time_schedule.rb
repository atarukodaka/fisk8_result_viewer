module CompetitionParser
  class SummaryParser
    class TimeSchedule
      attr_reader :data

      def initialize(array = [])
        @data = array
      end

      def start_date
        data.map { |d| d[:starting_time] }.min.to_date || raise
      end

      def end_date
        data.map { |d| d[:starting_time] }.max.to_date || raise
      end

      def timezone
        item = data.first || (return 'UTC')
        item[:starting_time].time_zone.name
      end

      def season
        SkateSeason.new(start_date)
      end

      def starting_time(category, segment)
        item = data.find { |d| d[:category] == category && d[:segment] == segment } || raise
        item[:starting_time]
      end
    end
  end
end
