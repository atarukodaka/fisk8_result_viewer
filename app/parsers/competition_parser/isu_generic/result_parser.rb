module CompetitionParser
  class IsuGeneric
    class ResultParser
      include Utils

      def callbacks
        {}
      end

      def columns
        {}
      end
      def get_rows(page)
        raise "implemente on derived class"
      end

      def get_headers(row)
        elems = row.xpath("th").presence || row.xpath("td")
        elems.map do |elem|
          elem.text.squish.gsub(/[[:space:]]/, '')
        end
      end
      ################
      def parse(url)
        puts "   --  parsing #{url}"
        page = get_url(url, read_option: 'r:iso-8859-1').presence || (return [])
        rows = get_rows(page)
        headers = get_headers(rows[0])
        ##
        rows[1..-1].map do |row|
          elems = row.xpath('td')
          next if elems.size == 1

          data = {}
          columns.each do |key, params|
            relevant_headers = [params[:header],].flatten

            
            col_number = headers.index {|d| relevant_headers.index(d)} ||
                         raise("no relevant column found: #{key}: #{relevant_headers}")
            elem = elems[col_number]
            data[key] =
              if (callback = params[:callback])
                callback.call(elem)
              else
                elem.text.squish
              end
          end
          data
        end.compact  ## rows
      end
    end
  end
end