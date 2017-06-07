module Fisk8ResultViewer
  module Skater
    class Parser
      include Utils
      
      URLS = {
        MEN: "http://www.isuresults.com/bios/fsbiosmen.htm",
        LADIES: "http://www.isuresults.com/bios/fsbiosladies.htm",
        PAIRS: "http://www.isuresults.com/bios/fsbiospairs.htm",
        :"ICE DANCE" => "http://www.isuresults.com/bios/fsbiosicedancing.htm",
      }
      def parse_skaters(categories)
        categories.map do |category|
          page = get_url(URLS[category])
          nation = ""
          page.xpath("//table[1]/tr").map do |row|
            parse_skater(row, category: category, default_nation: nation).tap {|s|
              nation = s[:nation]
            }
          end
        end.flatten
        #[{isu_number: 1, name: "foo"}]
      end
      def parse_skater(row, category:, default_nation: nil)
        nation = (n = row.xpath("td[1]").text.presence) ? n : default_nation
        name = row.xpath("td[3]").text
        row.xpath("td[3]/a/@href").text =~ /(\d+)\.htm$/
        isu_number = $1.to_i
        {
          isu_number: isu_number, nation: nation, name: name, category: category,
        }
      end
    end
  end
end
