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
      ts_item = time_schedule.select {|d|
        d[:category] == item[:category] && d[:segment] == item[:segment]
      }.first
      #starting_time = ts_item[:starting_time] if ts_time.present?
      data = item.slice(:category, :segment, :official_url, :score_url)
      data[:starting_time] = ts_item[:starting_time] if ts_item.present?
      data
    end
    ## check starting time for each segments
    default_starting_time = nil
    performed_segments.select {|d| d[:starting_time].nil?}.each do |item|
      default_starting_time ||= if (start_date = parse_start_date(page))
        start_date
      elsif (ps = performed_segments.select {|d| d[:starting_time]}.first)
        ps[:starting_time]
      else
        raise "no time schedule nor start date"
      end
      item[:starting_time] = default_starting_time
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
      ## start_date: time_schedule.map {|d| d[:starting_time]}.min.try(:to_date),
      ## end_date: time_schedule.map {|d| d[:starting_time]}.max.try(:to_date),
      start_date: performed_segments.map {|d| d[:starting_time]}.min.to_date,
      end_date: performed_segments.map {|d| d[:starting_time]}.max.to_date,
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
