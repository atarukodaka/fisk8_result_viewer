module Fisk8ResultViewer
  module Parsers
    class AutomnClassic < IsuGeneric
      module Competition
        class Parser < IsuGeneric::Competition::Parser
          def parse_name(page)
            page.xpath("//h1").first.text
          end
          def parse_city_country(page)
            [page.xpath("//dd[@class='tribe-venue']").text.strip, "CAN"]
          end
        end
      end
      Fisk8ResultViewer::Parsers.register(:autumn_classic, self)      
    end
  end
end

