require 'fisk8viewer/utils'

module Fisk8Viewer
  class Parser
    class CategoryResultParser
      include Fisk8Viewer::Utils

      def get_rows(page)
        fpl = page.xpath("//th[contains(text(), 'FPl.')]")
        return [] if fpl.blank?

        fpl.first.xpath("../../tr")
      end
      def parse_headers(row)
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
          when 'SP', 'SD'
            col_num[:short_ranking] = i
          when 'FS', 'FD'
            col_num[:free_ranking] = i
          end
        end
        col_num
      end
      
=begin
      def parse_ranking(row)
        row.xpath("td[1]").text.to_i
      end
      def parse_isu_number(row)
        href = row.xpath("td[2]/a/@href").text
        href =~ /([0-9]+)\.htm$/
        $1.to_i
      end
      def parse_skater_name(row)
        #normalize_skater_name(row.xpath("td[2]").text)
        row.xpath("td[2]").text
      end
      def parse_nation(row)
        row.xpath("td[3]").text =~ /([A-Z][A-Z][A-Z])/
        $1
      end
      def parse_rankings(row)
        size = row.xpath("td").size
        if size >= 6
          [row.xpath("td[5]").text.to_i, row.xpath("td[6]").text.to_i]
        elsif size == 5
          [row.xpath("td[5]").text.to_i, nil]
        else
          [nil, nil]
        end
      end
      def parse_points(row)
        row.xpath("td[4]").text.to_f
      end
      def parse_row(row)
        return {} if row.xpath("td").blank?
        short_ranking, free_ranking = parse_rankings(row)
        {
          ranking: parse_ranking(row),
          skater_name: parse_skater_name(row),
          isu_number: parse_isu_number(row),
          nation: parse_nation(row),
          points: parse_points(row),
          short_ranking: short_ranking.to_i,
          free_ranking: free_ranking.to_i,
        }
      end
=end      
      def parse(url)
        page = get_url(url)
        page.encoding = 'iso-8859-1'  # for umlaut support

        rows = get_rows(page)
        col_num = parse_headers(rows[0])
        rows[1..-1].map do |row|
          data = {}
          data[:ranking] = row.xpath("td")[col_num[:ranking]].text.to_i
          data[:skater_name] = row.xpath("td")[col_num[:skater_name]].text
          data[:nation] = row.xpath("td")[col_num[:nation]].text
          data[:points] = row.xpath("td")[col_num[:points]].text.to_f
          data[:short_ranking] = row.xpath("td")[col_num[:short_ranking]].text.to_i
          data[:free_ranking] = row.xpath("td")[col_num[:free_ranking]].text.to_i

          href = row.xpath("td")[col_num[:skater_name]].xpath("a/@href").text
          data[:isu_number] = (href =~ /([0-9]+)\.htm$/) ? $1.to_i : nil
          data
        end
      end
    end  # module
  end
end
