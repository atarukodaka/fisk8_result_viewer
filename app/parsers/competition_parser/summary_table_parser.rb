class CompetitionParser
  class SummaryTableParser < Parser
    include CompetitionParser::Utils

    def parse(page, base_url: '')
      elem = page.xpath("//*[text()='Category']").first || raise
      rows = elem.xpath('ancestor::table[1]//tr')
      category = ''

      rows.reject { |r| r.xpath('td').blank? }.map do |row|
        if (c = row.xpath('td[1]').text.presence)
          category = normalize_category(c)
        end
        segment = row.xpath('td[2]').text.squish.upcase
        next if (category.blank? && segment.blank?) ||
                row.xpath('td[3]').text.blank? || row.xpath('td[4]').text =~ /cancelled/ ||
                (row.xpath('td[1]').text.blank? && row.xpath('td[2]').text.blank?)

        if segment.blank?   ## category section
          {
            type: :category,
            category: category,
            result_url: parse_url_by_string(row, 'Result', base_url: base_url)
          }
        else    ## segment section
          {
            type: :segment,
            category: category,
            segment: segment,
            official_url: parse_url_by_column(row, 3, base_url: base_url),
            result_url: parse_url_by_column(row, 4, base_url: base_url),
            score_url: parse_url_by_column(row, 5, base_url: base_url)
          }
        end
      end.compact
    end

    def join_url(base_url, path)
      if base_url =~ /^(.*)\/.*\.html?$/
        File.join($1, path)
      else
        File.join(base_url, path)
      end
    end

    def parse_url_by_string(row, search_string, base_url: '')
      a_elem = nil
      Array(search_string).each do |string|
        xpath_normal = "td//a[contains(text(), '#{string}')]"
        xpath_csfin = "td//a[*[contains(text(), '#{string}')]]"
        if (elem = row.xpath(" #{xpath_normal} | #{xpath_csfin} ").first)
          a_elem = elem
          break
        end
      end
      # (a_elem) ? File.join(base_url, a_elem.attributes['href'].value) : nil
      (a_elem) ? join_url(base_url, a_elem.attributes['href'].value) : nil
    end

    def parse_url_by_column(row, column_number, base_url: '')
      # File.join(base_url, row.xpath("td[#{column_number}]//a/@href").text)
      join_url(base_url, row.xpath("td[#{column_number}]//a/@href").text)
    end
  end
end
