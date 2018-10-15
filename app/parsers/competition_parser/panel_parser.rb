class CompetitionParser
  class PanelParser < Parser
    def parse(url)
      page = get_url(url, read_option: 'r:iso-8859-1').presence || (return [])
      debug("-- parse panel: #{url}", indent: 3)
      func = "contains(text(), 'Function')"
      elem = page.xpath("//th[#{func}] | //td[#{func}]") || raise('no Function cell')
      rows = elem.xpath('ancestor::table[1]//tr')
      {
        judges: rows.map do |row|
          next unless row.xpath('td[1]').text =~ /^Judge No\.(\d)/

          {
            number: $1,
            name: normalize_name(row.xpath('td[2]').text),
            nation: normalize_nation(row.xpath('td[3]').text),
          }
        end.compact
      }
    end

    def normalize_name(text)
      text.scrub('?').gsub(/[[:space:]]/, ' ').sub(/^ *M[sr]\. */, '').strip
    end

    def normalize_nation(text)
      text.gsub(/[[:space:]]/, ' ').strip
    end
  end ## PanelParser
end
