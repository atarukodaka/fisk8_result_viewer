module Parsers
  class AutomnClassic < IsuGeneric
    class CompetitionParser < IsuGeneric::CompetitionParser
      def parse_name(page)
          page.xpath("//h1").first.text
      end
      def parse_city_country(page)
        [page.xpath("//dd[@class='tribe-venue']").text.strip, "CAN"]
      end
    end
    Parsers.register(:autumn_classic, self)      
  end
end

