module CompetitionParser
  class SegmentResultParser < CategoryResultParser
    def live_results?(page)
      page.xpath("//*[contains(text(), 'Live Results')]").present?
    end

    def get_rows(page)
      return nil if live_results?(page)

      xpath_str = "//th[contains(text(), ' Pl. ') or text()='Pl.'] | //td[text()='Pl.' or text()='PL.']"
      place_elem = page.xpath(xpath_str).first || raise("No Placement Cell found (#{self.class})")
      place_elem.xpath('../../tr')
    end

    def columns
      {
        ranking: { header_regex: /P[lL]\./ },
        skater_name: { header_regex: /Name/ },
        nation: { header_regex: /^Nation$/ },
        starting_number: { header_regex: /StN/, callback: elem_to_starting_number },
        isu_number:      { header_regex: /Name/, callback: elem_to_isu_number },
        tss: { header_regex: /TSS/ },
        tes: { header_regex: /TES/ },
        pcs: { header_regex: /PCS/ },
        deductions: { header_regex: /Ded/ },
      }
    end

    protected

    def elem_to_starting_number
      lambda { |elem|  elem.text.sub(/^#/, '').to_i }
    end
  end ## class
end
