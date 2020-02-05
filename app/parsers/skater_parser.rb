class SkaterParser < Parser
  # include Utils
  include LinkToHelper ## for isu_bio_url

  def parse_skaters(category, url)
    page = get_url(url)
    nation = ''
    page.xpath('//table[1]/tr').map do |row|
      parse_skater(row, category: category, default_nation: nation).tap { |s|
        nation = s[:nation]
      }
    end
  end

  def parse_skater(row, category:, default_nation: nil)
    nation = (n = row.xpath('td[1]').text.presence) ? n : default_nation
    name = row.xpath('td[3]').text
    row.xpath('td[3]/a/@href').text =~ /(\d+)\.htm$/
    isu_number = $1.to_i
    {
      isu_number: isu_number, nation: nation, name: name, category: category,
    }
  end

=begin
  def update_bio_last_updated_at(data, page)
    ## bio last updated at
    if page.xpath("//td/span[contains(., 'last update')]").first&.text =~ /last update: (.*)/
      begin
        data[:bio_updated_at] = $1.in_time_zone('UTC')
      rescue ArgumentError => e
        debug(e.message)
      end
    end
  end

  def normalize_birthday(data)
    if data[:birthday].present?
      begin
        data[:birthday] = Date.parse(data[:birthday])
      rescue ArgumentError => e
        debug(e.message)
      end
    end
  end
=end
  def parse_skater_details(isu_number)
    page = get_url(isu_bio_url(isu_number)) || raise("invalid isu number: #{isu_number}")

    if page.xpath("//head/meta[@name='Generator']")&.attribute('content')&.value =~ /FlexCel 6\.19\.5\.0/
      parse_skater_details_flexcel_6_19(page, isu_number)
    else
      parse_skater_details_standard1(page, isu_number)
    end
  end

  def parse_skater_details_flexcel_6_19(page, isu_number)
    #    FlexCel 6.19.5.0; format have been changed at feb2020
    data = {
      isu_number: isu_number,
      name: page.xpath("//table[1]/tr[4]/td[3]").text,
      nation: page.xpath("//table[1]/tr[6]/td[3]").text,
      category_type: page.xpath("//table[1]/tr[2]/td[1]").text.upcase,
    }
    tags = {
      'Date of birth' => :birthday,
      'Height' =>:height,
      'Home town' => :hometown,
      'Start sk. / Club' => :club,
      'Hobbies' => :hobbies,
      'Coach' => :coach,
      'Choreographer' => :choreographer,
      'Practice low season' => :practice_low_season,
      'Practice high season' => :practice_high_season,

    }
    page.xpath("//table[1]/tr").each do |tr|
      tag = tr.xpath("td[1]").text.sub(/:/, '')
      if key = tags[tag]
        data[key] = tr.xpath("td[2]").text
      end
    end
    data[:club] = data[:club].split(/ *\/ */).last if data[:club]
    data
  end
  def parse_skater_details_ver1(page, isu_number)

    #page = get_url(isu_bio_url(isu_number)) || raise("invalid isu number: #{isu_number}")
    data = { isu_number: isu_number }
    {
      nation:        'person_nationLabel',
      name:          'person_cnameLabel',
      category_type: 'CategoryLabel',
      birthday:      'person_dobLabel',
      height:        'person_heightLabel',
      hometown:      'person_htometownLabel',
      club:          'person_club_nameLabel',
      hobbies:       'person_hobbiesLabel',

      coach:         'person_media_information_coachLabel',
      choreographer: 'person_media_information_choreographerLabel',
      practice_low_season:  'person_media_information_practice_on_ice_low_seasonLabel',
      practice_high_season: 'person_media_information_on_ice_high_seasonLabel',

    }.each do |key, elem_id|
      data[key] = page.search("#FormView1_#{elem_id}").text.presence ||
                  page.search("#FormView2_#{elem_id}").text
    end

    #binding.pry
    #normalize_birthday(data)
    #update_bio_last_updated_at(data, page)
    if page.xpath("//td/span[contains(., 'last update')]").first&.text =~ /last update: (.*)/
      begin
        data[:bio_updated_at] = $1.in_time_zone('UTC')
      rescue ArgumentError => e
        debug(e.message)
      end
    end
    data
  end
end
