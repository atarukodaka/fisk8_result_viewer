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
    def parse(url, encoding: nil)
      page = get_url(url, encoding: encoding).presence || (return [])
      rows = get_rows(page) || (return [])
      headers = get_headers(rows[0])
      ##
      rows[1..-1].map do |row|
        #binding.pry #if self.class == CompetitionParser::SegmentResultParser
        next if row.attributes['style'].try(:value) =~ /display:\s*none/

        elems = row.xpath('td')
        next if elems.size == 1

        data = {}
        columns.each do |key, hash|
          elem = find_column(from: elems, headers: headers, to_match: hash[:header_regex]) || next
          if elem.blank?  ## TODO
            if !hash[:optional]
              raise("no relevant column: from #{elems}, headers: #{headers}, to match: #{hash[:header_regex]}")
            else
              next
            end
          end
          data[key] = (callback = hash[:callback]) ? callback.call(elem) : elem.text.squish
          # binding.pry if self.class == CompetitionParser::SegmentResultParser
        end

        next if invalid_skater_name?(data[:skater_name])

        data
      end.compact  ## rows
    end

    ## callback functions
    # protected

    def elem_to_i
      ->(elem) { elem.text.squish.to_i }
    end

    def elem_to_f
      ->(elem) { elem.text.squish.to_f }
    end

    def elem_to_isu_number
      lambda { |elem|
        href = elem.xpath('a/@href').text
        (href =~ /([0-9]+)\.htm$/) ? $1.to_i : nil
      }
    end

    private

    def find_column(from:, headers:, to_match:)
      col_number = headers.index { |d| d =~ to_match } || return  #|| raise("no relevant column: from #{from}, headers: #{headers}, to match: #{to_match}")
      from[col_number]
    end

    def invalid_skater_name?(skater_name)
      skater_name =~ /Final not Reached/i     ## wc2018 has 'Final not Reached' record
    end
  end
end
