module CompetitionParser
  class IsuGeneric
    class ResultParser
      include Utils
      def callbacks
        {
          to_i: lambda {|elem| elem.text.squish.to_i},
          to_f: lambda {|elem| elem.text.squish.to_f},
          isu_number: lambda {|elem|
              href = elem.xpath('a/@href').text
              (href =~ /([0-9]+)\.htm$/) ? $1.to_i : nil
            }
        }
      end

      def columns
        {
          name: { header: 'Name'},
          isu_number: { header: 'Name', callback: callbacks[:isu_number] },
          nation: { header: 'Nation' },
          
          ranking: { header: ['FPl.', 'PL'] , callback: callbacks[:to_i]},
          points: { header: 'Points', callback: callbacks[:to_f]},
          short_ranking: { header: ['SP', 'SD'], callback: callbacks[:to_i] },
          free_ranking: { header: ['FS', 'FD'], callback: callbacks[:to_i] },
        }
      end
      def get_rows(page)
        place_elem = page.xpath("//th[contains(text(), 'FPl')]").first ||
                     page.xpath("//th[contains(text(), 'Pl')]").first || 
                     page.xpath("//td[contains(text(), 'Pl')]").first || 
                     page.xpath("//td[contains(text(), 'PL')]").first  ## TODO: td or th ??
        return place_elem.xpath("../../tr")
      end
      def get_headers(row)
        row.children.map do |elem|
          elem.text.squish.gsub(/[[:space:]]/, '')
        end
      end
      def parse(url)
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
            
            col_number = headers.index {|d| relevant_headers.index(d)}
            elem = elems[col_number]
            data[key] =
              if (callback = params[:callback])
                callback.call(elem)
              else
                elem.text.squish
              end
          end
          data
        end  ## rows
      end
    end  ## class
  end
end
