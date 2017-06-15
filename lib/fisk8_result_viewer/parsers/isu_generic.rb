module Fisk8ResultViewer
  module Parsers
    class IsuGeneric
      class CompetitionParser < Fisk8ResultViewer::Competition::Parser
      end
      class CategoryResultParser < Fisk8ResultViewer::CategoryResult::Parser
      end
      class ScoreParser < Fisk8ResultViewer::Score::Parser
      end
=begin      
      module Competition
        class Parser < Fisk8ResultViewer::Competition::Parser
        end
      end
      module CategoryResult
        class Parser < Fisk8ResultViewer::CategoryResult::Parser
        end
      end
      module Score
        class Parser < Fisk8ResultViewer::Score::Parser
        end
      end
=end
      Fisk8ResultViewer::Parsers.register(:isu_generic, self)
    end
  end
end
