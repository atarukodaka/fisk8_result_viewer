class CompetitionParser
  module Extension
    class JapanOpen < CompetitionParser
      class TimeScheduleParser < CompetitionParser::TimeScheduleParser
        def parse(_page)
          []
        end
      end

      class CategoryResultParser < CompetitionParser::CategoryResultParser
        def columns
          {
            skater_name: { header_regex: /Competitor/  },
            skater_nation: { header_regex: /Nation/ },
            ranking: { header_regex: /PL/, callback: elem_to_i },
            points: { header_regex: /Points/, callback: elem_to_f },
          }
        end
      end

      class OfficialParser < CompetitionParser::OfficialParser
        def get_rows(page)
          super(page) || find_table_rows(page, 'Funciton', type: :match)  ## JO2015 typo
        end
      end
      class ScoreParser < CompetitionParser::ScoreParser
        def parse_skater(line, score)
          @last_line ||= ''
          name_re = %q([[:alpha:]1\.\- \/\']+)
          ## adding '1' for Mariya1 BAKUSHEVA
          ##   (see: http://www.pfsa.com.pl/results/1314/WC2013/CAT003EN.HTM)
          nation_re = '[A-Z][A-Z][A-Z]'
          re = /^(\d+) (#{name_re}) *(#{nation_re}) #?(\d+) ([\d\.]+) ([\d\.]+) ([\d\.]+) ([\d\.\-]+)/
          if line =~ re || "#{@last_line} #{line}" =~ re
            score.update(ranking: $1.to_i, skater_name: $2.strip, skater_nation: $3,
                         starting_number: $4.to_i, tss: $5.to_f, tes: $6.to_f,
                         pcs: $7.to_f, deductions: $8.to_f.abs * -1)
            :tes
          else
            @last_line = line
            :skater
          end
        end
      end
    end
  end
end
