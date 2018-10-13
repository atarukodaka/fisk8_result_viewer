module CompetitionParser
  class SummaryParser
    class Summary
      attr_accessor :data

      delegate :[], :[]=, :<<, :keys, :slice, to: :@data

      def initialize(hash)
        @data = hash
        @data[:category_results] ||= []
        @data[:segment_results] ||= []
      end

      def categories
        @data[:segment_results].map { |item| item[:category] }.uniq
      end

      def category_result(category)
        @data[:category_results].find { |d| d[:category] == category }
      end

      def segment_results_with(category:, validation: false)
        results = @data[:segment_results].select { |d| d[:category] == category }
        (validation) ? results.reject { |d| d[:result_url].blank? } : results
      end

      def category_result_url(category)
        category_result(category).try(:[], :result_url)
      end

      ################
      def start_date
        @data[:segment_results].reject { |d| d[:starting_time].nil? }.map { |d| d[:starting_time] }.min.to_date || raise
      end

      def end_date
        @data[:segment_results].reject { |d| d[:starting_time].nil? }.map { |d| d[:starting_time] }.max.to_date || raise
      end

      def season
        SkateSeason.new(start_date)
      end

      def timezone
        elem = @data[:segment_results].find { |d| d[:starting_time].present? }
        (elem) ? elem[:starting_time].time_zone.name : 'UTC'
      end

      def starting_time(category, segment)
        item = @data[:segment_results].find { |d| d[:category] == category && d[:segment] == segment } || raise
        item[:starting_time]
      end
    end
  end
end
