module Fisk8ResultViewer
  module CategoryResult
    class Parser
      include Utils
      include Contracts

      def get_rows(page)
        fpl = page.xpath("//th[contains(text(), 'FPl.')]")
        return [] if fpl.blank?

        fpl.first.xpath("../../tr")
      end
      Contract Nokogiri::XML::Element => Hash
      def get_column_numbers(row)
        col_num = {}
        row.xpath("th").each_with_index do |header, i|
          case header.text.strip
          when 'FPl.'
            col_num[:ranking] = i
          when 'Name'
            col_num[:skater_name] = i
          when 'Nation'
            col_num[:nation] = i
          when 'Points'
            col_num[:points] = i
          when 'SP', 'SD', 'OD'
            col_num[:short_ranking] = i
          when 'FS', 'FD'
            col_num[:free_ranking] = i
          end
        end
        col_num
      end
      Contract String, String => Array
      def parse_category_results(url, _category)
        begin
          page = get_url(url, read_option: 'r:iso-8859-1')
        rescue OpenURI::HTTPError
          ##http://www.kraso.sk/wp-content/uploads/sutaze/2014_2015/20141001_ont/html/CAT003RS.HTM returns 404 somehow
          logger.warn("!!! #{url} not found")
          return []
        end
        rows = get_rows(page)
        col_numbers = get_column_numbers(rows[0])

        rows[1..-1].map do |row|
          tds = row.xpath("td")
          data = {}
          [
           [:ranking, :int,], [:skater_name, :string], [:nation, :string],
           [:points, :float], [:short_ranking, :int], [:free_ranking, :int],
          ].each do |ary|
            key, type = ary
            col_num = col_numbers[key] || raise
            text = tds[col_num].text
            data[key] =
              case type
              when :int
                text.to_i
              when :string
                text.squish
              when :float
                text.to_f
              end
          end
          # isu_number by href
          col_num = col_numbers[:skater_name] || raise
          href = tds[col_num].xpath("a/@href").text
          data[:isu_number] = (href =~ /([0-9]+)\.htm$/) ? $1.to_i : nil
=begin          
          data = {
            ranking: tds[col_num[:ranking]].text.to_i,
            skater_name: tds[col_num[:skater_name]].text.squish,
            nation: tds[col_num[:nation]].text,
            points: tds[col_num[:points]].text.to_f,
            short_ranking: tds[col_num[:short_ranking]].text.to_i,
            free_ranking: tds[col_num[:free_ranking]].text.to_i,
          }
          href = row.xpath("td")[col_num[:skater_name]].xpath("a/@href").text
          data[:isu_number] = (href =~ /([0-9]+)\.htm$/) ? $1.to_i : nil
=end
          data
        end
      end
    end
  end
end
