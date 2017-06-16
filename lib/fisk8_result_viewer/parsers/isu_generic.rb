module Fisk8ResultViewer
  module Parsers
    class IsuGeneric < Fisk8ResultViewer::Parser
      class CompetitionParser < Fisk8ResultViewer::Parser::CompetitionParser
      end
      class CategoryResultParser < Fisk8ResultViewer::Parser::CategoryResultParser
      end
      class ScoreParser < Fisk8ResultViewer::Parser::ScoreParser
      end
      Fisk8ResultViewer::Parsers.register(:isu_generic, self)
    end
  end
end
