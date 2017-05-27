require 'fisk8viewer/parsers/isu_generic'

module Fisk8Viewer
  module Parsers
    class AutumnClassic < ISU_Generic
      class CompetitionSummaryParser < ISU_Generic::CompetitionSummaryParser
        def parse_name(page)
          page.xpath("//h1").first.text
        end
        def parse_city_country(page)
          [page.xpath("//dd[@class='tribe-venue']").text.strip, "CAN"]
        end
      end
      Fisk8Viewer::Parsers.register(:autumn_classic, self)
    end
  end
end
