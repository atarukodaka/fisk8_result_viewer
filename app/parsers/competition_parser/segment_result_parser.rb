class CompetitionParser
  class SegmentResultParser < ResultParser
    def parse(url, category, segment, encoding: nil)
      debug("-- parsing segment result for '%-10s/%s': %s" % [category, segment, url], indent: 3)
      super(url, encoding: encoding).map { |d| d[:category] = category; d[:segment] = segment; d }
      #binding.pry
      #a
    end

    def columns
      {
        skater_name:   { header_regex: /Name|Competitor/ },
        isu_number:    { header_regex: /Name|Competitor/, callback: elem_to_isu_number, },
        skater_nation:        { header_regex: /Nation|Nat\./ },

        ranking:       { header_regex: /F?P[lL]\.?/, callback: elem_to_i },
        tss:           { header_regex: /^TSS/, callback: elem_to_f },
        tes:           { header_regex: /^TES/, callback: elem_to_f },
        pcs:           { header_regex: /^PCS/, callback: elem_to_f },
        decutions:     { header_regex: /^Ded/, callback: elem_to_f },
        starting_number: { header_regex: /StN\./, callback: elem_to_starting_number },
      }
    end

    def get_rows(page)
      find_table_rows(page, ['Pl.', 'PL.'], type: :match) || (
        debug("No Placement Cell found (#{self.class})")
        nil
      )
    end

    def elem_to_starting_number
      ->(elem) { elem.text.sub(/^\#/, '').to_i }
    end
  end
end
