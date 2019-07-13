# coding: utf-8
class CompetitionParser
  module Extension
    class AllJapan < CompetitionParser
      def parse_city_country(page)
        ["", "JPN"]
      end

      def parse(site_url, *args)
        @encoding = "UTF-8"
        data = super(site_url, *args)
        if data[:time_schedule].blank?
          page = get_url(site_url, mode: "r:UTF-8") || []
          page.text =~ /(\d+)年(\d+)月(\d+)日/
          tm = Time.zone.local($1, $2, $3)
          data[:time_schedule] = data[:scores].map {|d| [d[:category], d[:segment]]}.uniq.map {|d|
            {
              starting_time: tm,
              category: d[0],
              segment: d[1]
            }
          }
        end
        data
      end

      class SummaryTableParser < CompetitionParser::SummaryTableParser
        def initialize(*args)
          super(*args)
          @search_strings[:summary_table_column] = 'カテゴリー'
          @search_strings[:result] = '競技結果'
        end
        def normalize_category(category)
          category.sub(/男子/, 'MEN').sub(/女子/, 'LADIES').sub(/ペア/, 'PAIRS').sub(/アイスダンス/, 'ICE DANCE')
        end
      end

      class TimeScheduleParser < CompetitionParser::TimeScheduleParser
        def parse(page, date_format: nil)
          timezone = "Asia/Tokyo"
          elem = page.xpath("//*[text()='期日']").first #|| return( []) # raise("no time schedule table found")
          return [] if elem.nil?
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

      class OfficialParser < CompetitionParser::OfficialParser
        def initialize(*args)
          super(*args)
          @search_string = '役 職'
          @encoding = 'UTF-8'
        end
      end

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
          #name_re = %q([亜-熙ぁ-んァ-ヶ ]+)
          #name_team_re = '[亜-熙ぁ-んァ-ヶA-Za-z0-9]+'
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
