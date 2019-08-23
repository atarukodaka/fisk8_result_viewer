  class CompetitionParser < Parser
  def parse(site_url, encoding: nil)
    page = get_url(site_url, encoding: encoding) || return
    city, country = parse_city_country(page)
    {
      name: parse_name(page),
      city: city,
      country: country,
      site_url: site_url,
      time_schedule: parse_time_schedule(page),
      summary_table: parse_summary_table(page, base_url: site_url)
    }
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
