class CompetitionParser
  class IsuGeneric
    class SegmentResultParser < CategoryResultParser
      def callbacks
        super.merge(starting_number: lambda { |elem|
                                       elem.text.sub(/^#/, '').to_i
                                     })
      end

      def get_rows(page)
        return(nil) if page.xpath("//*[contains(text(), 'Live Results')]").present?

        place_elem =
          page.xpath("//th[contains(text(), ' Pl. ')]").first ||
          # http://www.isuresults.com/results/season1718/csger2017/SEG001.HTM has spaces
          page.xpath("//th[text()='Pl.']").first ||
          page.xpath("//td[text()='PL.']").first ||                  # gpjpn
          page.xpath("//td[text()='Pl.']").first ||                  # wtt2017
          raise("No Placement Cell found (#{self.class})")

        place_elem.xpath('../../tr')
      end

      def columns
        {
          ranking: { header_regex: /P[lL]\./ },
          skater_name: { header_regex: /Name/ },
          nation: { header_regex: /^Nation$/ },
          starting_number: { header_regex: /StN/, callback: callbacks[:starting_number] },
          isu_number:      { header_regex: /Name/, callback: callbacks[:isu_number] },
          tss: { header_regex: /TSS/ },
          tes: { header_regex: /TES/ },
          pcs: { header_regex: /PCS/ },
          deductions: { header_regex: /Ded/ },
        }
      end
    end ## class
  end
end
