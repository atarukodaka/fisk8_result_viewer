class Parser
  class ResultParser

    include Utils

    def parse(url)
      page = get_url(url, read_option: 'r:iso-8859-1').presence || (return [])
      rows = get_rows(page)
      col_numbers = get_column_numbers(rows[0])
      rows[1..-1].map do |row|
        tds = row.xpath("td")
        next if tds.size == 1
        data = {}
        
        [
         [:ranking, :int,], [:skater_name, :string], [:nation, :string],
         [:points, :float], [:short_ranking, :int], [:free_ranking, :int],
        ].map do |ary|
          key, type = ary
          col_num = col_numbers[key] || raise("parsing error in category results")
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

        col_num = col_numbers[:skater_name] || raise("parsing error in category results")
        href = tds[col_num].xpath("a/@href").text
        data[:isu_number] = (href =~ /([0-9]+)\.htm$/) ? $1.to_i : nil
        data
      end.compact ## rows.each
    end ## def
    ################################################################
    protected
    def get_rows(page)
      fpl = page.xpath("//th[contains(text(), 'FPl.')]")
      return [] if fpl.blank?

      fpl.first.xpath("../../tr")
    end
    
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
  end
end
