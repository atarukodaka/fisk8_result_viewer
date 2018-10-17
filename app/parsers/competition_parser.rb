class CompetitionParser < Parser
  attr_accessor :categories, :season_from, :season_to

  def parse(site_url, date_format: nil, categories: nil, season_from: nil, season_to: nil)
    page = get_url(site_url) || return
    time_schedule = parse_time_schedule(page, date_format: date_format)
    season = SkateSeason.new(time_schedule.map { |d| d[:starting_time] }.min)
    unless season.between?(season_from, season_to)
      debug("skipping...season %s out of range [%s, %s]" % [season.season, season_from, season_to], indent: 3)
      return nil
    end

    city, country = parse_city_country(page)

    # @categories = categories
    data = {
      site_url: site_url,
      name: parse_name(page),
      country: country,
      city: city,
      time_schedule: time_schedule,
      officials: [],
      category_results: [],
      scores: [],
    }
    parsers = {
      category_result: CategoryResultParser.new(verbose: verbose),
      official: OfficialParser.new(verbose: verbose),
      score: ScoreParser.new(verbose: verbose),
    }
    summary_table = parse_summary_table(page, base_url: site_url)
    summary_table.select { |d| categories.include?(d[:category]) && d[:type] == :category }.each do |item|
      data[:category_results].push(*parsers[:category_result].parse(item[:result_url], item[:category]))
    end
    summary_table.select { |d| categories.include?(d[:category]) && d[:type] == :segment }.each do |item|
      category, segment = item.values_at(:category, :segment)
      data[:officials].push(*parsers[:official].parse(item[:official_url], category, segment))
      data[:scores].push(*parsers[:score].parse(item[:score_url], category, segment))
    end
    data
  end

  ################
  def parse_time_schedule(page, date_format: nil)
    TimeScheduleParser.new.parse(page, date_format: date_format)
  end

  def parse_summary_table(page, base_url: nil)
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
