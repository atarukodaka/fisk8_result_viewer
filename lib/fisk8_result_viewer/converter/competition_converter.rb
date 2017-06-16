module Fisk8ResultViewer
  module Converter
    class CompetitionConverter
      extend Forwardable
      def_delegators :@data, :[]
      attr_reader :data

      def initialize(parsed_hash)
        @data = parsed_hash
        @data[:result_summary] ||= []
        @data[:time_schedule] ||= []      

        ## dates
        @data[:start_date] = @data[:time_schedule].map {|e| e[:time]}.min
        @data[:end_date] = @data[:time_schedule].map {|e| e[:time]}.max

        # add year name unless it contains any year info
        @data[:name] = @data[:name].to_s + " #{@data[:start_date].try(:year)}" unless @data[:name] =~ /[0-9][0-9][0-9][0-9]/

        ## type, short_name
        #@data[:competition_type] = competition_type
        #@data[:cid] = get_cid

        ## season
        if @data[:start_date].present?
          year, month = @data[:start_date].year, @data[:start_date].month
          year -= 1 if month <= 6
          @data[:season] = "%04d-%02d" % [year, (year+1) % 100]
        end
        ################
        keys = [:site_url, :name, :city, :country, :start_date, :end_date, :season, ]
        @model = ::Competition.create(@data.slice(*keys))
      end
      def to_model
        @model
      end
      ################
      def categories
        data[:result_summary].map {|h| h[:category]}.sort.uniq
      end
      def segments(category)
        data[:result_summary].select {|h| h[:category] == category && h[:segment].present?}.map {|h| h[:segment]}.uniq
      end
      def result_url(category, segment=nil)
        if segment.nil?
          find_row(:result_summary, category, "").try(:[], :result_url)
        else
          find_row(:result_summary, category, segment).try(:[], :result_url)
        end
      end
      def score_url(category, segment)
        find_row(:result_summary, category, segment).try(:[], :score_url)
      end
      def starting_time(category, segment)
        find_row(:time_schedule, category, segment).try(:[], :time)
      end
      def method_missing(name, *args)
        @data.send(name, *args)
      end
      ################
      private
      def find_row(key, category, segment)
        data[key].select {|h|
          h[:category] == category && h[:segment] == segment
        }.first

      end
    end
  end
end

