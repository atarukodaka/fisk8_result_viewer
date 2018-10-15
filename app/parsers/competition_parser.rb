class CompetitionParser < Parser
  def parse(site_url)
    page = get_url(site_url) || return
    data = {
      site_url: site_url,
      name: parse_name(page),
      country: parse_country(page),
      city: parse_city(page),
      time_schedule: parse_time_schedule(page),
      officials: [],
      category_results: [],
      segment_results: [],
      scores: [],
    }
    summary_table = parse_summary_table(page)
    time_schedule = 

    summary_table.select {|d| d[:type] == :category}.each do |item|
      data[:category_results].push(*parse_category_result(item[:result_url], item[:category]))
    end
    summary_table.select {|d| d[:type] == :official}.each do |item|
      data[:officials].push(*parse_official(item[:official_url], item[:category], item[:segment]))
    end
    summary_table.select {|d| d[:type] == :segment}.each do |item|
      ## scores
      data[:scores].push(*parse_score(item[:score_url], item[:category], item[:segment]))
    end
    data
  end
  def parse_name(page)
      page.title.strip
  end
  def parse_country(page)
    "USA"
  end
  def parse_city(page)
    ""
  end
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
  def parse_category_result(result_url, category)
    [
      {category: "LADIES", ranking: 1,
       skater_name: "Kaetlyn OSMOND", skater_nation: "CAN", isu_number: 12655,
       points: 223.23, short_ranking: 4, free_ranking: 1}
    ]
  end
  def parse_official(official_url, category, segment)
    [
      {official_type: :judge, number: 1, panel_name: "Matjaz KRUSEC", panel_nation: "" },
    ]
  end
=begin
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
