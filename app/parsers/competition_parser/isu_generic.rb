module CompetitionParser
  class IsuGeneric
    def initialize
      @parser = {
        summary: "#{self.class}::SummaryParser".constantize.new,
        result: "#{self.class}::ResultParser".constantize.new,
        score: "#{self.class}::ScoreParser".constantize.new,
        panel: "#{self.class}::PanelParser".constantize.new,
      }

    end

    def parse_summary(url)
      @parser[:summary].parse(url)
    end

    def parse_result(url)
      @parser[:result].parse(url)
    end

    def parse_score(url)
      @parser[:score].parse(url)
    end

    def parse_panel(url)
      @parser[:panel].parse(url)
    end
  end
end
