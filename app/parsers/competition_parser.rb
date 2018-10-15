class CompetitionParser < Parser
  attr_accessor :categories, :season_from, :season_to
  
  def parse(site_url, date_format: nil, categories: nil, season_from: nil, season_to: nil)
    page = get_url(site_url) || return
    city, country = parse_city_country(page)
    @categories = categories
    data = {
      site_url: site_url,
      name: parse_name(page),
      country: country,
      city: city,
      time_schedule: parse_time_schedule(page, date_format: date_format),
      officials: [],
      category_results: [],
      scores: [],
    }
    ## TODO: check season
    return nil unless SkateSeason.new(data[:time_schedule].map {|d| d[:starting_time]}.min).between?(season_from, season_to)
    
    #summary_table = SummaryTableParser.new.parse(page, base_url: site_url)
    summary_table = parse_summary_table(page, base_url: site_url)
    summary_table.select {|d| categories.include?(d[:category]) && d[:type] == :category}.each do |item|
      data[:category_results].push(*CategoryResultParser.new(verbose: verbose).parse(item[:result_url], item[:category]))
    end
    summary_table.select {|d| categories.include?(d[:category]) && d[:type] == :segment}.each do |item|
      data[:officials].push(*OfficialParser.parse(item[:official_url], item[:category], item[:segment]))
      data[:scores].push(*ScoreParser.new(verbose: verbose).parse(item[:score_url], item[:category], item[:segment]))
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
      city = city.to_s.sub(/ *$/, '').sub(/,.*$/, '').sub(/ *\(.*\)$/, '').sub!(/ *\/.*$/, '')
      [city, country]
    else
      [str, nil] ## to be set in competition.update()
    end
  end
=begin
  def parse_summary_table(page)
    [
      {type: :category, category: "LADIES", result_url: nil },
      {type: :segment, category: "LADIES", segment: "SHORT PROGRAM", official_url: nil, result_url: nil, score_url: nil},
      #{type: :segment, category: "LADIES", segment: "FREE SKATING", official_url: nil, result_url: nil, score_url: nil}
]
  end

  def parse_time_schedule(page)
    [
      {category: "LADIES", segment: "SHORT PROGRAM", starting_time: Time.now},
      #{category: "LADIES", segment: "FREE SKATING", starting_time: Time.now}
    ]
  end
=end
=begin
  def parse_category_result(result_url, category)
    [
      {category: "LADIES", ranking: 1,
       skater_name: "Kaetlyn OSMOND", skater_nation: "CAN", isu_number: 12655,
       points: 223.23, short_ranking: 4, free_ranking: 1}
    ]
  end

  def parse_official(official_url, category, segment)
    [
      {official_type: :judge, number: 1, category: "LADIES", segment: "SHORT PROGRAM",
       panel_name: "Matjaz KRUSEC", panel_nation: "" },
    ]
  end

  def parse_segment_result(result_url, category, segment)
    [
      {category: "LADIES", segment: "SHORT PROGRAM",
       raking: 1, skater_name: "Carolina KOSTNER", skater_natin: "ITA", isu_number: 4864,
       starting_numer: 33, tss: 80.27, tes: 41.30, pcs: 38.97, deductions: 0,
      }
    ]
  end
=end
  def parse_score(score_url, category, segment)
    [
      {
        category: "LADIES", segment: "SHORT PROGRAM",        
        ranking: 4, skater_name: "Carolina KOSTNER", skater_nation: "ITA", isu_number: 4864,
        starting_number: 33, tss: 80.27, tes: 41.30, pcs: 38.97, deductions: 0,
        elements: [{number: 1, name: "3F+3T", base_value: 9.6, goe: 1.8, judges: "3 3 2",
                    value: 11.40}],
        components: [{number: 1, name: "Skating Skills", factor: 0.8, judges: "9.75 10 9.5",
                      value: 9.61}],
      }
    ]
  end
end
