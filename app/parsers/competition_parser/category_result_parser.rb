class CompetitionParser
  class CategoryResultParser < ResultParser
    def parse(url, category, encoding: nil)
      message("-- parsing category result for '%-10s': %s" % [category, url], indent: 3)
      super(url, encoding: encoding).map { |d| d[:category] = category; d }
    end

    def columns
      {
        skater_name:   { header_regex: /Name/ },
        isu_number:    { header_regex: /Name/, callback: elem_to_isu_number, },
        skater_nation:        { header_regex: /Nation|Nat\./ },

        ranking:       { header_regex: /F?P[lL]\.?/, callback: elem_to_i },
        points:        { header_regex: /Points/, callback: elem_to_f },
        short_ranking: { header_regex: /SP|SD|OD|RD/, callback: elem_to_i },
        free_ranking:  { header_regex: /FS|FD/, callback: elem_to_f },
      }
    end

    def get_rows(page)
      find_table_rows(page, ['FPl', 'FPl.', 'PL']) || raise("No Placement Cell found (#{self.class})")
    end
  end ## class
end
