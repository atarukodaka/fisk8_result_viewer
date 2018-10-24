module AcceptCategories
  refine Array do
    def accept_categories(categories)
      categories ||= Category.all.map(&:name)
      select { |d| categories.include?(d[:category])   }
      #select { |d| categories.nil? || categories.include?(d[:category])   }
    end
  end
end
module SelectType
  refine Array do
    def select_type(type)
      select { |d| d[:type] == type }
    end
  end
end

################
class CompetitionParser < Parser
  using AcceptCategories
  using SelectType
  attr_accessor :categories, :season_from, :season_to

  def parse(site_url, date_format: nil, categories: nil, season_from: nil, season_to: nil)
    page = get_url(site_url) || return
    time_schedule = parse_time_schedule(page, date_format: date_format)
    return nil unless season_to_parse?(time_schedule, from: season_from, to: season_to)

    data = {
      name: parse_name(page),
      time_schedule: time_schedule,
      site_url: site_url,
      officials: [], category_results: [], scores: [],
    }
    data[:city], data[:country] = parse_city_country(page)

    cr_parser = CategoryResultParser.new(verbose: verbose)
    official_parser = OfficialParser.new(verbose: verbose)
    score_parser = ScoreParser.new(verbose: verbose)

    summary_table = parse_summary_table(page, base_url: site_url).accept_categories(categories)
    summary_table.select_type(:category).each do |item|
      data[:category_results].push(*cr_parser.parse(item[:result_url], item[:category]))
    end
    summary_table.select_type(:segment).each do |item|
      category, segment = item.values_at(:category, :segment)
      data[:officials].push(*official_parser.parse(item[:official_url], category, segment))
      data[:scores].push(*score_parser.parse(item[:score_url], category, segment))
    end
    data
  end

  ################
  def season_to_parse?(time_schedule, from:, to:)
    season = SkateSeason.new(time_schedule.map { |d| d[:starting_time] }.min)
    return true if season.between?(from, to)

    debug('skipping...season %s out of range [%s, %s]' % [season.season, from, to], indent: 3)
    false
  end

  def parse_time_schedule(page, date_format: nil)
    TimeScheduleParser.new.parse(page, date_format: date_format)
  end

  def parse_summary_table(page, base_url: '')
    SummaryTableParser.new.parse(page, base_url: base_url)
  end

  def parse_name(page)
    page.title.strip
  end

  def parse_city_country(page)
    node = page.search('td.caption3').presence || page.xpath('//h3') || raise
    str = (node.present?) ? node.first.text.strip : ''
    if str =~ %r{^(.*) *[,/] ([A-Z][A-Z][A-Z]) *$}
      city, country = $1, $2
      city = city.to_s.sub(/ *$/, '').sub(/,.*$/, '').sub(/ *\(.*\)$/, '').sub(/ *\/.*$/, '')
      [city, country]
    else
      [str, nil] ## to be set in competition.update()
    end
  end
end
