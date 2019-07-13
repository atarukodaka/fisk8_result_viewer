class CompetitionParser
  class OfficialParser < Parser
    def initialize(*args)
      super(*args)
      @search_string = 'Function'
      @encoding = 'iso-8859-1'
    end

    def parse(url, category, segment)
      page = get_url(url, mode: "r:#{@encoding}").presence || (return [])
      debug("-- parsing officials: #{url}", indent: 3)
      #func = "contains(text(), @search_string)"
      #binding.pry
      #elem = page.xpath("//th[#{func}] | //td[#{func}]") || raise('no Function cell')
      #rows = elem.xpath('ancestor::table[1]//tr')
      rows = find_table_rows(page, @search_string, type: :match) || raise('no Function cell')
      rows.map do |row|
        data = {
          category: category,
          segment: segment,
          function_type: nil,
          number: nil,
          function: nil,
          panel_name: normalize_name(row.xpath('td[2]').text.squish),
          panel_nation: normalize_nation(row.xpath('td[3]').text),
        }
        td1 = row.xpath('td[1]').text
        if /Referee/.match?(td1)
          data[:function_type] = :technical
          data[:function] = td1
        elsif /Technical/.match?(td1)
          data[:function_type] = :technical
          data[:function] = td1
        elsif td1 =~ /^Judge No\.(\d)/
          data[:function_type] = :judge
          data[:function] = td1
          data[:number] = $1
        else
          next
        end
        data
      end.compact
    end

    def normalize_name(text)
      text.scrub('?').gsub(/[[:space:]]/, ' ').sub(/^ *M[sr]\. */, '').strip
    end

    def normalize_nation(text)
      text.gsub(/[[:space:]]/, ' ').strip.sub(/ISU/, '')
    end
  end
end
