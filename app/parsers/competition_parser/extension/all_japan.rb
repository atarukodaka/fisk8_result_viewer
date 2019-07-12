# coding: utf-8
class CompetitionParser
  module Extension
    class AllJapan < CompetitionParser
      def parse_city_country(page)
        ["", "JPN"]
      end

      class SummaryTableParser < CompetitionParser::SummaryTableParser
        def initialize
          super
          @search_strings[:summary_table_column] = 'カテゴリー'
          @search_strings[:result] = '競技結果'
        end
        def normalize_category(category)
          category.sub(/男子/, 'MEN').sub(/女子/, 'LADIES').sub(/ペア/, 'PAIRS').sub(/アイスダンス/, 'ICE DANCE')
        end
      end

      class TimeScheduleParser < CompetitionParser::TimeScheduleParser
        def parse(page, date_format: nil)
          timezone = "Japan"
          elem = page.xpath("//*[text()='期日']").first || raise "no time schedule table found"
          rows = elem.xpath('ancestor::table[1]//tr')

          date = nil
          data = rows[1..-1].map do |row|
            tds = row.xpath("td")
            if tds.count == 4
              date, time, category, segment = tds.map(&:text)
            else
              time, category, segment = tds.map(&:text)
            end
            dt_tm_str = "#{date} #{time}"
            tm = if date_format.present?
              Time.strptime(dt_str, "#{date_format} %H:%M:%S")
            else
              dt_tm_str
            end.in_time_zone(ActiveSupport::TimeZone[timezone])
            category = normalize_category(category)
            {
              starting_time: tm,
              category: normalize_category(category),
              segment: segment.upcase,
            }
          end.compact

          data
        end
        def normalize_category(category)
          category.sub(/男子/, 'MEN').sub(/女子/, 'LADIES').sub(/ペア/, 'PAIRS').sub(/アイスダンス/, 'ICE DANCE')
        end
      end
      ## rubocop:enable all

      class CategoryResultParser < CompetitionParser::CategoryResultParser
        def initialize(*args)
            super(*args)
            @encoding = 'UTF-8'
        end
        def columns
          hash = super
          hash[:skater_name] = { header_regex: /選手名/ }
          hash.delete(:isu_number)
          hash.delete(:skater_nation)
          hash
        end
      end
      class ScoreParser < CompetitionParser::ScoreParser
        def parse_skater(line, score)
          name_re = %q([亜-熙ぁ-んァ-ヶ ]+)
          name_team_re = '[亜-熙ぁ-んァ-ヶA-Za-z0-9]+'
          if line =~ /^(\d+) (.*) ([^ ]+) (\d+) ([\d\.]+) ([\d\.]+) ([\d\.]+) ([\d\.\-]+)/
            score.update(ranking: $1.to_i, skater_name: $2.strip, skater_nation: 'JPN',
                         starting_number: $4.to_i, tss: $5.to_f, tes: $6.to_f,
                         pcs: $7.to_f, deductions: $8.to_f.abs * -1)
            :tes
          else
            :skater
          end
        end
      end

    end
  end
end
