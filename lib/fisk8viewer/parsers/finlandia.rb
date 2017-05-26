require 'fisk8viewer/parsers/isu_generic'

module Fisk8Viewer
  module Parsers
    class Finlandia < ISU_Generic
      class CompetitionSummaryParser < ISU_Generic::CompetitionSummaryParser
        def parse_city_country(page)
          page.xpath("//h3")[0].text.strip
        end
      end
      class CategoryResultParser < ISU_Generic::CategoryResultParser
        def get_category(page)
          page.xpath("//h2[2]").text.upcase.strip
        end
        def parse_isu_number(row)
          nil
        end
      end
      Fisk8Viewer::Parsers.register(:finlandia, self)
    end ## class
  end
end

    
