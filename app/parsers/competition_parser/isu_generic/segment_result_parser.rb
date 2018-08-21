module CompetitionParser
  class IsuGeneric
    class SegmentResultParser < ResultParser
      def callbacks
        super.merge(starting_number: lambda {|elem|
                      elem.text.sub(/^#/, '').to_i
                    })
      end
      def get_rows(page)
        place_elem =
          page.xpath("//th[text()='Pl.']").first || 
          page.xpath("//td[text()='PL.']").first ||
          page.xpath("//th[contains(text(), ' Pl. ')]").first      # http://www.isuresults.com/results/season1718/csger2017/SEG001.HTM
        raise "No Placement Cell found (#{self.class})" if place_elem.nil?
        return place_elem.xpath("../../tr")
      end
      def columns
        {
          ranking: { header: ['Pl.', 'PL.', 'FPl.'] },
          skater_name: { header: "Name" },
          nation: { header: "Nation" },
          starting_number: { header: "StN.", callback: callbacks[:starting_number] },
          isu_number: { header: "Name", callback: callbacks[:isu_number] },
        }
      end
    end ## class
  end
end
