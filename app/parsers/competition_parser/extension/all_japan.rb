class CompetitionParser
  module Extension
    class AllJapan < CompetitionParser
      def parse_city_country(_page)
        ['', 'JPN']
      end

      def parse_name(page)
        super(page) =~ /第([0-9０-９]+)回.*/
        "第#{$1.tr('０-９', '0-9')}回全日本フィギュアスケート選手権大会"
      end

      def parse(site_url, options) # *args)
        data = super(site_url, options) # *args)
        if data[:start_date].nil?
          page = get_url(site_url, encoding: options[:encoding]) || []
          page.text =~ /(\d+)年(\d+)月(\d+)日/
          tm = Time.utc($1, $2, $3).in_time_zone('Asia/Tokyo')
          #data[:time_schedule] = data[:scores].map {|d| [d[:category], d[:segment]]}.uniq.map {|d|
          data[:time_schedule].each do |item|
            item[:starting_time] = tm
          end
          data[:start_date] = tm.to_date
          data[:end_data] = tm.to_date
        end
        data
      end

      class SummaryTableParser < CompetitionParser::SummaryTableParser
        def get_summary_table_rows(page)
          find_table_rows(page, 'カテゴリー') || raise('no summary table found')
        end

        def parse_category_section(row, category, base_url: nil)
          hash = super(row, category, base_url: base_url)
          hash[:result_url] = parse_url_by_string(row, '競技結果', base_url: base_url)
          hash
        end

        def normalize_category(category)
          category.gsub(/シングル/, '').sub(/男子/, 'MEN').sub(/女子/, 'LADIES').sub(/ペア/, 'PAIRS').sub(/アイスダンス/, 'ICE DANCE')
        end
      end

      class TimeScheduleParser < CompetitionParser::TimeScheduleParser
        def get_time_schedule_rows(page)
          find_table_rows(page, '期日') || []
        end

        def normalize_category(category)
          category.sub(/男子/, 'MEN').sub(/女子/, 'LADIES').sub(/ペア/, 'PAIRS').sub(/アイスダンス/, 'ICE DANCE')
        end
      end

      class OfficialParser < CompetitionParser::OfficialParser
        def get_rows(page)
          find_table_rows(page, '役', type: :match)
        end
      end

      class SegmentResultParser < CompetitionParser::SegmentResultParser
        def columns
          hash = super
          hash[:skater_name] = { header_regex: /選手名/ }
          hash.delete(:isu_number)
          hash.delete(:skater_nation)
          hash
        end
      end
      class CategoryResultParser < CompetitionParser::CategoryResultParser
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
          if line =~ /^(\d+) (.*) ([^ ]+) #?(\d+) ([\d\.]+) ([\d\.]+) ([\d\.]+) ([\d\.\-]+)/
            score.update(ranking: $1.to_i, skater_name: $2.strip, skater_nation: 'JPN',
                         starting_number: $4.to_i, tss: $5.to_f, tes: $6.to_f,
                         pcs: $7.to_f, deductions: $8.to_f.abs * -1)
            :tes
          elsif line =~ /^(\d+) (.*) ([^ ]+) ([\d\.]+) ([\d\.]+) ([\d\.]+) ([\d\.\-]+)/
            score.update(ranking: $1.to_i, skater_name: $2.strip, skater_nation: 'JPN',
                         starting_number: 0, tss: $4.to_f, tes: $5.to_f,
                         pcs: $6.to_f, deductions: $7.to_f.abs * -1)
            ## 2008-9 or older score sheets dont have skating number
            :tes
          else
            :skater
          end
        end
      end
    end
  end
end
