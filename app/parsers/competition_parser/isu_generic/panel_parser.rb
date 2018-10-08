class CompetitionParser
  class IsuGeneric
    class PanelParser < Parser
      def parse(url)
        page = get_url(url, read_option: 'r:iso-8859-1').presence || (return [])
        debug("   -- parse panel: #{url}")
        elem = page.xpath("//th[contains(text(), 'Function')]").presence ||
               page.xpath("//td[contains(text(), 'Function')]").presence || []
        rows = elem.xpath('ancestor::table[1]//tr')

        {
          judges: rows.map do |row|
            next unless row.xpath('td[1]').text =~ /^Judge No\.(\d)/

            {
              number: $1,
              name:   row.xpath('td[2]').text.scrub('?').gsub(/[[:space:]]/, ' ').sub(/^ *M[sr]\. */, '').strip,
              nation: row.xpath('td[3]').text.gsub(/[[:space:]]/, ' ').strip,
            }
          end.compact
        }
      end
    end ## PanelParser
  end
end
