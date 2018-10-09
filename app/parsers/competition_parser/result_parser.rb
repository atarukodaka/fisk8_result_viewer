module CompetitionParser
  class ResultParser < Parser
    def callbacks
      {}
    end

    def columns
      {}
    end

    def get_rows(_page)
      raise 'implemente on derived class'
    end

    def get_headers(row)
      elems = row.xpath('th').presence || row.xpath('td')
      elems.map do |elem|
        elem.text.squish.gsub(/[[:space:]]/, '')
      end
    end

    ################
    def parse(url)
      debug("   --  parsing result: #{url}")

      page = get_url(url, read_option: 'r:iso-8859-1').presence || (return [])
      rows = get_rows(page) || (return [])
      headers = get_headers(rows[0])
      ##
      rows[1..-1].map do |row|
        elems = row.xpath('td')
        next if elems.size == 1

        data = {}
        columns.each do |key, hash|
          elem = find_column(from: elems, headers: headers, to_match: hash[:header_regex]) || next
          data[key] =
            if (callback = hash[:callback])
              callback.call(elem)
            else
              elem.text.squish
            end
        end
        next if invalid_skater_name?(data[:skater_name])

        data
      end.compact ## rows
    end

    private

    def find_column(from: , headers: , to_match: )
      col_number = headers.index { |d| d =~ to_match } || raise("no relevant column")
      from[col_number]
    end
    def invalid_skater_name?(skater_name)
      skater_name == 'Final not Reached'     ## wc2018 has 'Final not Reached' record
    end
  end
end
