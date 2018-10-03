class CompetitionParser
  class IsuGeneric
    class PanelParser < Parser
      def parse(url)
        page = get_url(url).presence || (return [])
        puts "   -- parse panel: #{url}" if @verbose

        elem = page.xpath("//th[contains(text(), 'Function')]").presence ||
               page.xpath("//td[contains(text(), 'Function')]").presence ||  []
        rows = elem.xpath('ancestor::table[1]//tr')
        hash = { judges: [] }
        rows.each do |row|
          if row.xpath('td[1]').text =~ /^Judge No\.(\d)/
            hash[:judges][$1.to_i] =
              {
                number: $1,
                name:   row.xpath('td[2]').text.scrub('?').gsub(/[[:space:]]/, ' ').sub(/^ *M[sr]\. */, '').strip,
                nation: row.xpath('td[3]').text.gsub(/[[:space:]]/, ' ').strip,
              }
          end
        end
        hash
      end
    end ## PanelParser
  end
end
