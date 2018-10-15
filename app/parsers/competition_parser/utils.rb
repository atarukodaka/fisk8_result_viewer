class CompetitionParser
  module Utils
    def normalize_category(category)
      category.squish.upcase.gsub(/^PAIR SKATING$/, 'PAIRS')
        .gsub(/^SENIOR /, '').gsub(/ SINGLE SKATING/, '').gsub(/ SKATING/, '')
    end
  end
end
