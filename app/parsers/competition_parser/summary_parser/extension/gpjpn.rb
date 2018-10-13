module CompetitionParser
  class SummaryParser
    module Extension
      module Gpjpn
        def parse_city_country(_page)
          ['', 'JPN']
        end

        def header_element(page)
          page.xpath("//*[text()='Men']").first
        end

        def parse_summary_table(page, url: '')
          data = { category_results: [], segment_results: [] }
          category = ''
          current_segment_results = nil

          header_element(page).xpath('../../tr').each do |row|
            if row.xpath("td/a[contains(text(), 'Entries')]").present?
              category = row.xpath('td[1]').text.upcase
              data[:category_results] << {
                category: category,
                result_url: parse_url_by_string(row, 'Result', base_url: url),
              }
            elsif row.xpath('td').count == 2   ##  new section
              current_segment_results = {
                category: category,
                segment: row.xpath('td[1]').text.upcase,
                panel_url: parse_url_by_string(row, 'Panel of Judges', base_url: url),
              }
            elsif (result_url = parse_url_by_string(row, 'Starting Order', base_url: url))
              current_segment_results[:result_url] = result_url
            elsif (score_url =  parse_url_by_string(row, 'Judges Score', base_url: url))
              current_segment_results[:score_url] = score_url
              data[:segment_results] << current_segment_results
              current_segment_results = nil
            else
              raise 'parse error'
            end
          end
          data   ## ensure to return hash
        end

        ## this site is nightmare again: TD doesnt wraped with TR
        def parse_time_schedule(page, date_format: '') ## rubocop:disable Lint/UnusedMethodArgument
          Time.zone ||= 'UTC'
          header_elem = page.xpath("//*[text()='Date']").first
          table = header_elem.xpath('../..')

          i = 1;  b_header = true; summary = []
          date = nil; time = nil; category = ''; segment = ''
          timezone = 'Asia/Tokyo'

          table.children.each do |elem|
            case elem.name
            when 'text'
              next
            when 'td'
              case i
              when 1 then date = elem.text
              when 2 then time = elem.text
              when 3 then category = elem.text.upcase
              when 4
                segment = elem.text.upcase
                summary << {
                  category: category,
                  segment:  segment,
                  starting_time:     "#{date} #{time}".in_time_zone(timezone),
                }
              end
              (i == 4) ? i = 1 : i += 1
            when 'tr'
              if b_header # skip if header
                b_header = false
                next
              end
              summary << {
                category: elem.xpath('td[2]').text.upcase,
                segment:  elem.xpath('td[3]').text.upcase,
                starting_time:     "#{date} #{elem.xpath('td[1]').text}".in_time_zone(timezone),
              }
            end
          end
          summary
        end
      end
    end
  end
end
