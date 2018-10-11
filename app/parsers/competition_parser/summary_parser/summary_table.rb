module CompetitionParser
  class SummaryParser
    class SummaryTable
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
    end
  end
end
