class CompetitionParser
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
        columns.each do |key, params|
          col_number = headers.index { |d| d =~ params[:header_regex] } ||
                       raise("no relevant column: #{key}")
          elem = elems[col_number] || next
          data[key] =
            if (callback = params[:callback])
              callback.call(elem)
            else
              elem.text.squish
            end
        end
        next if data[:skater_name] == 'Final not Reached'     ## wc2018 has 'Final not Reached' record

        data
      end.compact ## rows
    end
  end
end
