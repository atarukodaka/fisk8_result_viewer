module CompetitionParser
  class IsuGeneric
    def initialize
      @parser = {
        summary: "#{self.class}::SummaryParser".constantize.new,
        category_result: "#{self.class}::CategoryResultParser".constantize.new,
        segment_result: "#{self.class}::SegmentResultParser".constantize.new,
        score: "#{self.class}::ScoreParser".constantize.new,
#        panel: "#{self.class}::PanelParser".constantize.new,
      }

    end

    def parse_summary(url, date_format: )
      @parser[:summary].parse(url, date_format: date_format)
    end

    def parse_category_result(url)
      @parser[:category_result].parse(url)
    end

    def parse_segment_result(url)
      @parser[:segment_result].parse(url)
    end

    def parse_score(url)
      @parser[:score].parse(url)
    end

=begin
    def parse_panel(url)
      @parser[:panel].parse(url)
    end
=end
  end
end

CompetitionParser::IsuGeneric::SummaryParser
CompetitionParser::IsuGeneric::CategoryResultParser
CompetitionParser::IsuGeneric::SegmentResultParser
CompetitionParser::IsuGeneric::ScoreParser
#CompetitionParser::IsuGeneric::PanelParser
