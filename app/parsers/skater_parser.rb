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

  def update_bio_last_updated_at(data, page)
    ## bio last updated at
    if (elem = page.xpath("//td/span[contains(., 'last update')]").first)
      if elem.text =~ /last update: (.*)/
        begin
          data[:bio_updated_at] = $1.in_time_zone('UTC')
        rescue ArgumentError => e
          debug(e.message)
        end
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

  def parse_skater_details(isu_number)
    page = get_url(isu_bio_url(isu_number)) || raise("invalid isu number: #{isu_number}")
    data = { isu_number: isu_number }
    {
      nation:        'person_nationLabel',
      name:          'person_cnameLabel',
      category_type:      'CategoryLabel',
      birthday:      'person_dobLabel',
      height:        'person_heightLabel',
      hometown:      'person_htometownLabel',
      club:          'person_club_nameLabel',
      hobbies:       'person_hobbiesLabel',

      coach:         'person_media_information_coachLabel',
      choreographer: 'person_media_information_choreographerLabel',
    }.each do |key, elem_id|
      data[key] = page.search("#FormView1_#{elem_id}").text.presence ||
                  page.search("#FormView2_#{elem_id}").text
    end

    normalize_birthday(data)
    update_bio_last_updated_at(data, page)
    data
  end
end
