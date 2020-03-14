  class CompetitionParser < Parser
    def parse_summary(site_url, encoding: nil)
      page = get_url(site_url, encoding: encoding) || return
      city, country = parse_city_country(page)

      data = {
        name: parse_name(page),
        city: city,
        country: country,
        site_url: site_url,
        time_schedule: parse_time_schedule(page),
        scores: [],
        segment_results: [],
        officials: [],
      }
      if data[:time_schedule].present?
        data[:start_date] = data[:time_schedule].map {|d| d[:starting_time]}.min.try(:to_date)
        data[:end_date] = data[:time_schedule].map {|d| d[:starting_time]}.max.to_date
        data[:timezone] = data[:time_schedule].first[:starting_time].time_zone.name
      end
      data[:summary_table] = parse_summary_table(page, base_url: site_url)
      data
    end

    ##
    def parse(site_url, encoding: nil, season_skipper: nil, category_skipper: nil)
      page = get_url(site_url, encoding: encoding) || return
      city, country = parse_city_country(page)

      data = {
        name: parse_name(page),
      city: city,
      country: country,
      site_url: site_url,
      time_schedule: parse_time_schedule(page),
      scores: [],
      segment_results: [],
      officials: [],
    }
    if data[:time_schedule].present?
      data[:start_date] = data[:time_schedule].map {|d| d[:starting_time]}.min.try(:to_date)
      data[:end_date] = data[:time_schedule].map {|d| d[:starting_time]}.max.to_date
      data[:timezone] = data[:time_schedule].first[:starting_time].time_zone.name
      return if season_skipper&.skip?(data[:start_date])
    end
    data[:summary_table] = parse_summary_table(page, base_url: site_url)

    ## category result
    data[:category_results] = []
    data[:summary_table].select {|d| d[:type] == :category}.each do |item|
      next if category_skipper&.skip?(item[:category])
      debug('===  %s ===' % [ item[:category] ], indent: 2)

      if item[:result_url]   ## wtt doenst have category result
        data[:category_results].push(*parse_category_result(item[:result_url], item[:category]))
      end
    end

    data[:summary_table].select {|d| d[:type] == :segment}.each do |item|
      next if category_skipper&.skip?(item[:category])
      data[:segment_results].push(*parse_segment_result(item[:result_url], item[:category], item[:segment]))
      data[:scores].push(*parse_score(item[:score_url], item[:category], item[:segment]))
      data[:officials].push(*parse_officials(item[:official_url], item[:category], item[:segment]))
    end

    data
  end

  ################
  def get_parser(ptype)
    @parsers ||= {}
    @parsers[ptype] ||= [self.class, "#{ptype.to_s.camelize}Parser"].join('::').constantize.new(verbose: verbose)
  end

  def parse_time_schedule(page)
    get_parser(:time_schedule).parse(page)
  end

  def parse_summary_table(page, base_url: '')
    get_parser(:summary_table).parse(page, base_url: base_url)
  end

  def parse_category_result(url, category)
    get_parser(:category_result).parse(url, category)
  end

  def parse_segment_result(url, category, segment)
    get_parser(:segment_result).parse(url, category, segment)
  end

  def parse_score(url, category, segment)
    get_parser(:score).parse(url, category, segment)
  end

  def parse_officials(url, category, segment)
    get_parser(:official).parse(url, category, segment)
  end

  def parse_start_date(page)
    text = page.text
    if text =~ /([A-Z][a-z\.]+ [0-9]+, [0-9]+)/
      $1.in_time_zone.to_date
    end
  end
  def parse_name(page)
    page.title.strip
  end

  def parse_city_country(page)
    node = page.search('td.caption3').presence || page.xpath('//h3') || raise
    str = (node.present?) ? node.first.text.strip : ''
    city, country = str.split(/ *\/ */)

    if city.nil? & country.nil?
      ;
    elsif country.nil?
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
