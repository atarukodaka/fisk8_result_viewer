class CompetitionParser
  class IsuGeneric
  end
end

## load relevant parsers

# rubocop:disable Lint/Void
CompetitionParser::IsuGeneric::SummaryParser
CompetitionParser::IsuGeneric::CategoryResultParser
CompetitionParser::IsuGeneric::SegmentResultParser
CompetitionParser::IsuGeneric::ScoreParser
CompetitionParser::IsuGeneric::PanelParser
# rubocop:enable Lint/Void
