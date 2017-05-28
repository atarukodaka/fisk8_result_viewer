module Fisk8Viewer
  module Parsers
    class Finlandia_2013 < ISU_Generic
      class CompetitionSummaryParser < ISU_Generic::CompetitionSummaryParser
        def get_time_schedule_rows(page)
          #page.xpath("//table[*[th[text()='Date']]]").xpath(".//tr")
          page.xpath("//table[.//span[text()='Date']]").xpath(".//tr")
        end
      end
      ## register
      Fisk8Viewer::Parsers.register(:finlandia_2013, self)
    end ## class
  end
end

