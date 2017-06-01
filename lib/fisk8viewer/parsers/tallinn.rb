module Fisk8Viewer
  module Parsers
    class Tanllinn_2013 < ISU_Generic
      class CompetitionSummaryParser < ISU_Generic::CompetitionSummaryParser
        def get_time_schedule_rows(page)
          #page.xpath("//table[*[th[text()='Date']]]").xpath(".//tr")
          page.xpath("//table[.//*[text()='Date']]").xpath(".//tr")
        end
        def parse_summary_table(page)
          rows = page.xpath("//table[.//font[text()='Category']]").xpath(".//tr")
          category = ""
          summary = []

          rows.each do |row|
            next if row.xpath("td").blank?

            if (c = row.xpath("td[1]").text.presence)
              category = c.gsub(/^Challenger Series - /, '').gsub(/^Senior /, '').upcase.strip if c != 'ISU link'
            end
            segment = row.xpath("td[2]").text.upcase.strip.gsub(/[\r\n]+/, '').gsub(/ +/, ' ')
            next if category.blank? && segment.blank?

            result_url = row.xpath("td[4]//a/@href").text
            score_url = row.xpath("td[5]//a/@href").text

            summary << {
              category: category,
              segment: segment,
              result_url: (result_url.present?) ? URI.join(@url, result_url).to_s: "",
              score_url: (score_url.present?) ? URI.join(@url, score_url).to_s : "",
            }
          end
          binding.pry
          summary
        end

        
      end
      ## register
      Fisk8Viewer::Parsers.register(:tallinn, self)
    end ## class
  end
end

