module Fisk8ResultViewer
  module Parsers
    class IsuGeneric < Fisk8ResultViewer::Parser
      class CompetitionParser < Fisk8ResultViewer::Competition::Parser
      end
      class CategoryResultParser < Fisk8ResultViewer::CategoryResult::Parser
      end
      class ScoreParser < Fisk8ResultViewer::Score::Parser
      end
      Fisk8ResultViewer::Parsers.register(:isu_generic, self)
    end
  end
end
