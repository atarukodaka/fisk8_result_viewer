module CompetitionParser
  class IsuGeneric
    class PanelParser
      include Utils

      def parse(url)
        page = get_url(url).presence || (return [])
        elem = page.xpath("//th[contains(text(), 'Function')]").presence || []
        rows = elem.xpath('ancestor::table[1]//tr')
        hash = {judges: []}
        rows.each do |row|
          if row.xpath("td[1]").text =~ /^Judge No\.(\d)/
            hash[:judges][$1.to_i] = 
              {
                name: row.xpath("td[2]").text,
                nation: row.xpath("td[3]").text,
              }
          end
        end
        hash
      end
    end ## PanelParser
  end
end

      
