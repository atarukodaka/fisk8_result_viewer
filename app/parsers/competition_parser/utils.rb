class CompetitionParser
  module Utils
    def normalize_category(category)
      #      category.squish.upcase.gsub(/^PAIR SKATING$/, 'PAIRS')
      #        .gsub(/^SENIOR /, '').gsub(/ SINGLE SKATING/, '').gsub(/ SKATING/, '')
      category.upcase.gsub(/^SEINOR/, '').gsub(/SKATING/, '').gsub(/SINGLE/, '').gsub(/PAIR\b/, 'PAIRS').squish
    end
  end
end
