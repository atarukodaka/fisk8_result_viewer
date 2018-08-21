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
          skater_name: { header: 'Name'},
          isu_number: { header: 'Name', callback: callbacks[:isu_number] },
          nation: { header: 'Nation' },
          
          ranking: { header: ['FPl.', 'PL', 'PL.'] , callback: callbacks[:to_i]},
          points: { header: 'Points', callback: callbacks[:to_f]},
          short_ranking: { header: ['SP', 'SD', 'OD'], callback: callbacks[:to_i] },
          free_ranking: { header: ['FS', 'FD'], callback: callbacks[:to_i] },
        }
      end
      def get_rows(page)
        place_elem =
          page.xpath("//th[text()='FPl']").first ||
          page.xpath("//th[text()='FPl.']").first ||
          page.xpath("//td[text()='PL']").first     ## gpjpn
        
#          page.xpath("//th[contains(text(), 'FPl')]").first || ## TODO: td or th ??
#          page.xpath("//td[contains(text(), 'PL')]").first     ## gpjpn
        raise "No Placement Cell found (#{self.class})" if place_elem.nil?
        return place_elem.xpath("../../tr")
      end
      def get_headers(row)
        elems = row.xpath("th").presence || row.xpath("td")
        elems.map do |elem|
          elem.text.squish.gsub(/[[:space:]]/, '')
        end
      end
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
            #binding.pry if self.class == CompetitionParser::Gpjpn::SegmentResultParser
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
    end  ## class
  end
end
