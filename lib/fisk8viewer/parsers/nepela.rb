require 'fisk8viewer/parsers/finlandia'

module Fisk8Viewer
  module Parsers
    class Nepela < Finlandia
      class CategoryResultParser < Finlandia::CategoryResultParser
        def parse_nation(row)
          row.xpath("td[4]").text =~ /([A-Z][A-Z][A-Z])/
          $1
        end
        def parse_points(row)
          row.xpath("td[5]").text.to_f
        end
        def parse_rankings(row)
          [row.xpath("td[6]").text.to_i, row.xpath("td[7]").text.to_i]
        end
      end
      Fisk8Viewer::Parsers.register(:finlandia, self)
    end ## class
  end
end

