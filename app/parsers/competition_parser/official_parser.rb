class CompetitionParser
  class OfficialParser < Parser
=begin
    def initialize(*args)
      super(*args)
#      @search_string = 'Function'
    end
=end
    def get_rows(page)
      find_table_rows(page, 'Function', type: :match)
    end

    def parse(url, category, segment, encoding: nil)
      page = get_url(url, encoding: encoding).presence || (return [])
      debug("-- parsing officials: #{url}", indent: 3)

      rows = get_rows(page) || raise('table not found')
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
          data[:function_type] = :referee
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
