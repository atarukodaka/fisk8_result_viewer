module AcceptCategories
  refine Array do
    def accept_categories(categories)
      categories ||= Category.all.map(&:name)
      select { |d| categories.include?(d[:category])   }
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

  def parse(site_url, date_format: nil, categories: nil, season_options: {}, encoding: 'iso-8859-1')
    page = get_url(site_url, encoding: encoding) || return
    summary_table = parse_summary_table(page, base_url: site_url).accept_categories(categories)
    time_schedule = parse_time_schedule(page, date_format: date_format)
    return nil unless season_to_parse?(time_schedule, season_options)

    city, country = parse_city_country(page)

    category_results = summary_table.select_type(:category).map do |item|
      parse_category_result(item[:result_url], item[:category], encoding: encoding)
    end.flatten

    officials = []
    scores = []
    summary_table.select_type(:segment).each do |item|
      category, segment = item.values_at(:category, :segment)
      officials.push(*parse_official(item[:official_url], category, segment, encoding: encoding))
      scores.push(*parse_score(item[:score_url], category, segment))
    end

    {
      name: parse_name(page),
      time_schedule: time_schedule,
      city: city, country: country,
      site_url: site_url,
      officials: officials, category_results: category_results, scores: scores,
    }
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

  [:time_schedule, :summary_table, :category_result, :score, :official].each do |ptype|
    define_method("parse_#{ptype}"){|*args|
      get_parser(ptype).parse(*args)
    }
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
