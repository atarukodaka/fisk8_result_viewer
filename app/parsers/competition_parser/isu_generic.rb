module CompetitionParser
  class IsuGeneric
    def initialize
      @parser = {
        summary: "#{self.class}::SummaryParser".constantize.new,
        result: "#{self.class}::ResultParser".constantize.new,
        score: "#{self.class}::ScoreParser".constantize.new,
#        panel: "#{self.class}::PanelParser".constantize.new,
      }

    end

    def parse_summary(url, date_format: )
      @parser[:summary].parse(url, date_format: date_format)
    end

    def parse_result(url)
      @parser[:result].parse(url)
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
CompetitionParser::IsuGeneric::ResultParser
CompetitionParser::IsuGeneric::ScoreParser
#CompetitionParser::IsuGeneric::PanelParser
