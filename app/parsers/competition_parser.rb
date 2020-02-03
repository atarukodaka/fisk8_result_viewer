  class CompetitionParser < Parser
  def parse(site_url, encoding: nil, categories: [], season_skipper: nil)
    page = get_url(site_url, encoding: encoding) || return
    city, country = parse_city_country(page)
    #time_schedule =
    data = {
      name: parse_name(page),
      city: city,
      country: country,
      site_url: site_url,
      time_schedule: parse_time_schedule(page),
      summary_table: parse_summary_table(page, base_url: site_url),
    }
    if data[:time_schedule].present?
      data[:start_date] = data[:time_schedule].map {|d| d[:starting_time]}.min.try(:to_date)
      data[:end_date] = data[:time_schedule].map {|d| d[:starting_time]}.max.to_date
      data[:timezone] = data[:time_schedule].first[:starting_time].time_zone.name
      if season_skipper&.skip?(SkateSeason.new(data[:start_date]))
        return
      end
    end

    ## category result
    data[:category_results] = []
    data[:summary_table].select {|d| d[:type] == :category}.each do |item|
      next if categories.present? && !categories.include?(item[:category])
      debug('===  %s ===' % [ item[:category] ], indent: 2)

      if item[:result_url]   ## wtt doenst have category result
        data[:category_results].push(*parse_category_result(item[:result_url], item[:category]))
      end
    end

    ## segment result
    data[:scores] = []
    data[:segment_results] = []
    data[:officials] = []
    data[:summary_table].select {|d| d[:type] == :segment}.each do |item|
      next if categories.present? && !categories.include?(item[:category])
      #parse_segment_result(item[:result_url], item[:category], item[:segment])
      #scores = parse_score(item[:score_url], item[:category], item[:segment])
      #segment_results = parse_segment_result(item[:score_url], item[:category], item[:segment]))
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
