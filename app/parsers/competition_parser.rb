module AcceptCategories
  refine Array do
    def accept_categories(categories)
      categories ||= Category.all.map(&:name)
      select { |d| categories.include?(d[:category])   }
      # select { |d| categories.nil? || categories.include?(d[:category])   }
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

  def parse(site_url, date_format: nil, categories: nil, season_options: {})
    page = get_url(site_url, mode: "r:#{@encoding}") || return
    summary_table = parse_summary_table(page, base_url: site_url).accept_categories(categories)
    time_schedule = parse_time_schedule(page, date_format: date_format)
    return nil unless season_to_parse?(time_schedule, season_options)

    data = {
      name: parse_name(page),
      time_schedule: time_schedule,
      site_url: site_url,
      officials: [], category_results: [], scores: [],
    }
    data[:city], data[:country] = parse_city_country(page)

    summary_table.select_type(:category).each do |item|
      data[:category_results].push(*parse_category_result(item[:result_url], item[:category]))
    end
    summary_table.select_type(:segment).each do |item|
      category, segment = item.values_at(:category, :segment)
      data[:officials].push(*parse_officials(item[:official_url], category, segment))
      data[:scores].push(*parse_score(item[:score_url], category, segment))
    end
    data
  end

  ################
  def season_to_parse?(time_schedule, season_options)
    this_season = SkateSeason.new(time_schedule.map { |d| d[:starting_time] }.min)
    season = season_options[:season]
    from = (season) ? season : season_options[:season_from]
    to = (season) ? season : season_options[:season_to]

    return true if this_season.between?(from, to)

    debug('skipping...season %s out of range [%s, %s]' % [this_season, from, to], indent: 3)
    false
  end

  def get_parser(ptype)
    @parsers ||= {}
    @parsers[ptype] ||= [self.class, "#{ptype.to_s.camelize}Parser"].join('::').constantize.new(verbose: verbose)
  end

  def parse_time_schedule(page, date_format: nil)
    get_parser(:time_schedule).parse(page, date_format: date_format)
  end

  def parse_summary_table(page, base_url: '')
    get_parser(:summary_table).parse(page, base_url: base_url)
  end

  def parse_category_result(url, category)
    get_parser(:category_result).parse(url, category)
  end

  def parse_score(url, category, segment)
    get_parser(:score).parse(url, category, segment)
  end

  def parse_officials(url, category, segment)
    get_parser(:official).parse(url, category, segment)
  end

  def parse_name(page)
    page.title.strip
  end

  def parse_city_country(page)
    node = page.search('td.caption3').presence || page.xpath('//h3') || raise
    str = (node.present?) ? node.first.text.strip : ''
    city, country = str.split(/ *\/ */)

    if country.nil?
      city, country = city.split(/ *, */)
      unless /^[A-Z][A-Z][A-Z]$/.match?(country)
        country = nil
      end
    elsif !/^[A-Z][A-Z][A-Z]$/.match?(country)
      if str =~ /^(.*) *([A-Z][A-Z][A-Z])$/
        country, city = $2, $1.sub(/, $/, '')
      else
        country = nil
      end
    end
    [city, country]
  end
end
