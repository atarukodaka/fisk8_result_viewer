module CompetitionParser
  class PanelParser < Parser
    def self.parse(url)
      self.new.parse(url)
    end

    def parse(url)
      page = get_url(url, read_option: 'r:iso-8859-1').presence || (return [])
      debug("   -- parse panel: #{url}")
      func = "contains(text(), 'Function')"
      elem = page.xpath("//th[#{func}] | //td[#{func}]") || raise('no Function cell')
      rows = elem.xpath('ancestor::table[1]//tr')
      {
        judges: rows.map do |row|
          next unless row.xpath('td[1]').text =~ /^Judge No\.(\d)/

          {
            number: $1,
            name: row.xpath('td[2]').text.scrub('?').gsub(/[[:space:]]/, ' ').sub(/^ *M[sr]\. */, '').strip,
            nation: row.xpath('td[3]').text.gsub(/[[:space:]]/, ' ').strip,
          }
        end.compact
      }
    end
  end ## PanelParser
end
