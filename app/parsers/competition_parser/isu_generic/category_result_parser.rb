class CompetitionParser
  class IsuGeneric
    class CategoryResultParser < ResultParser

      def callbacks
        {
          to_i:       lambda {|elem| elem.text.squish.to_i},
          to_f:       lambda {|elem| elem.text.squish.to_f},
          isu_number: lambda {|elem|
              href = elem.xpath('a/@href').text
              (href =~ /([0-9]+)\.htm$/) ? $1.to_i : nil
            }
        }
      end

      def columns
        {
          skater_name:   { header: 'Name' },
          isu_number:    { header: 'Name', callback: callbacks[:isu_number] },
          nation:        { header: 'Nation' },

          ranking:       { header: ['FPl.', 'PL', 'PL.'] , callback: callbacks[:to_i] },
          points:        { header: 'Points', callback: callbacks[:to_f] },
          short_ranking: { header: ['SP', 'SD', 'OD', 'RD'], callback: callbacks[:to_i] },
          free_ranking:  { header: ['FS', 'FD'], callback: callbacks[:to_i] },
        }
      end

      def get_rows(page)
        place_elem =
          page.xpath("//th[text()='FPl']").first ||
          page.xpath("//th[text()='FPl.']").first ||
          page.xpath("//td[text()='PL']").first     ## gpjpn
        raise "No Placement Cell found (#{self.class})" if place_elem.nil?
        return place_elem.xpath('../../tr')
      end
    end  ## class
  end
end
