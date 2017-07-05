class Parsers
  class IsuGeneric
    class CompetitionParser < Parser::CompetitionParser
    end
    class CategoryResultParser < Parser::CategoryResultParser
    end
    class ScoreParser < Parser::ScoreParser
    end
  end
end


=begin
module Parsers
  class IsuGeneric < Parser
    class CompetitionParser < Parser::CompetitionParser
    end
    class CategoryResultParser < Parser::CategoryResultParser
    end
    class ScoreParser < Parser::ScoreParser
    end
    Parsers.register(:isu_generic, self)
  end
end
=end
