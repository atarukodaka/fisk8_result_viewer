class SkaterParser
  include Utils
  include LinkToHelper
  
  def parse_skaters(category, url)
    page = get_url(url)
    puts "#{category}: #{url}"
    nation = ""
    page.xpath("//table[1]/tr").map do |row|
      parse_skater(row, category: category, default_nation: nation).tap {|s|
        nation = s[:nation]
      }
    end
  end
  def parse_skater(row, category:, default_nation: nil)
    nation = (n = row.xpath("td[1]").text.presence) ? n : default_nation
    name = row.xpath("td[3]").text
    row.xpath("td[3]/a/@href").text =~ /(\d+)\.htm$/
    isu_number = $1.to_i
    {
      isu_number: isu_number, nation: nation, name: name, category: category,
    }
  end
  def parse_skater_details(isu_number)
    page = get_url(isu_bio_url(isu_number))

    data = {}
    {
      birthday: "person_dobLabel",
      height: "person_heightLabel",
      hometown: "person_htometownLabel",
      club: "person_club_nameLabel",
      hobbies: "person_hobbiesLabel",
      
      coach: "person_media_information_coachLabel",
      choreographer: "person_media_information_choreographerLabel",
    }.each do |key, elem_id|
      data[key] = page.search("#FormView1_#{elem_id}").text.presence ||
                  page.search("#FormView2_#{elem_id}").text
    end

    if data[:birthday].present?
      begin
        data[:birthday] = Date.parse(data[:birthday])
      rescue ArgumentError =>e
        puts e.message
      end
    end
    ## bio last updated at
    if (elem = page.xpath("//td/span[contains(., 'last update')]").first)
      if elem.text =~ /last update: (.*)/
        begin
          data[:bio_updated_at] =$1.in_time_zone('UTC')
        rescue ArgumentError => e
          puts e.message
        end
      end
    end
     data
  end
end
