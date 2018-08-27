class SkaterParser
  include Utils
  
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
    
  end
end
