module CompetitionParser
  class CategoryResultParser < ResultParser
    def callbacks
      {
        to_i:       ->(elem) { elem.text.squish.to_i },
        to_f:       ->(elem) { elem.text.squish.to_f },
        isu_number: lambda { |elem|
                      href = elem.xpath('a/@href').text
                      (href =~ /([0-9]+)\.htm$/) ? $1.to_i : nil
                    }
      }
    end

    def columns
      {
        skater_name:   { header_regex: /Name/ },
        isu_number:    { header_regex: /Name/, callback: callbacks[:isu_number] },
        nation:        { header_regex: /Nation/ },

        ranking:       { header_regex: /F?P[lL]\.?/, callback: callbacks[:to_i] },
        points:        { header_regex: /Points/, callback: callbacks[:to_f] },
        short_ranking: { header_regex: /SP|SD|OD|RD/, callback: callbacks[:to_i] },
        free_ranking:  { header_regex: /FS|FD/, callback: callbacks[:to_i] },
      }
    end

    def get_rows(page)
      place_elem =
        page.xpath("//th[text()='FPl' or text()='FPl.'] | //td[text()='PL']").first ||
=begin
        page.xpath("//th[text()='FPl']").first ||
        page.xpath("//th[text()='FPl.']").first ||
        page.xpath("//td[text()='PL']").first || ## gpjpn
=end
        raise("No Placement Cell found (#{self.class})")

      place_elem.xpath('../../tr')
    end
  end ## class
end
