class CompetitionParser < Parser
  def parse(site_url, encoding: nil)
    page = get_url(site_url, encoding: encoding) || return
    summary_table = parse_summary_table(page, base_url: site_url)
    time_schedule = parse_time_schedule(page)

    performed_categories = summary_table.select {|d| d[:type] == :category }.map do |item|
      {
        category: item[:category],
        result_url: item[:result_url],
      }
    end
    performed_segments = summary_table.select {|d| d[:type] == :segment}.map do |item|
      {
        starting_time: time_schedule.select {|d|
          d[:category] == item[:category] && d[:segment] == item[:segment]
        }.first.try(:[], :starting_time) || Time.now,
        category: item[:category],
        segment: item[:segment],
        official_url: item[:official_url],
        score_url: item[:score_url],
      }
    end
    ## for team trophy
    performed_segments.pluck(:category).uniq.each do |category|
      unless performed_categories.find {|d| d[:category] == category}
        performed_categories.push( { category: category })
      end
    end

    data = {
      name: parse_name(page),
      site_url: site_url,
      performed_categories: performed_categories,
      performed_segments: performed_segments,
      start_date: time_schedule.map {|d| d[:starting_time]}.min.try(:to_date),
      end_date: time_schedule.map {|d| d[:starting_time]}.max.try(:to_date),
    }
    data[:city], data[:country] = parse_city_country(page)
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
