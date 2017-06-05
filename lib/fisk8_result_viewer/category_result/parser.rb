module Fisk8ResultViewer
  module CategoryResult
    class Parser
      include Utils
      include Contracts

      Contract Mechanize::Page => Nokogiri::XML::NodeSet
      def get_rows(page)
        fpl = page.xpath("//th[contains(text(), 'FPl.')]")
        return [] if fpl.blank?

        fpl.first.xpath("../../tr")
      end
      Contract Nokogiri::XML::Element => Hash
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
          when 'SP', 'SD', 'OD'
            col_num[:short_ranking] = i
          when 'FS', 'FD'
            col_num[:free_ranking] = i
          end
        end
        col_num
      end
      Contract String, String => Array
      def parse_category_results(url, category)
        page = get_url(url)
        return [] if page.nil?
        rows = get_rows(page)
        col_num = parse_headers(rows[0])
        rows[1..-1].map do |row|
          tds = row.xpath("td")
          data = {
            ranking: tds[col_num[:ranking]].text.to_i,
            skater_name: tds[col_num[:skater_name]].text.gsub(/  */, ' ').strip,
            nation: tds[col_num[:nation]].text,
            points: tds[col_num[:points]].text.to_f,
            short_ranking: tds[col_num[:short_ranking]].text.to_i,
            free_ranking: tds[col_num[:free_ranking]].text.to_i,
          }

          href = row.xpath("td")[col_num[:skater_name]].xpath("a/@href").text
          data[:isu_number] = (href =~ /([0-9]+)\.htm$/) ? $1.to_i : nil
          data
        end
      end
    end
  end
end
