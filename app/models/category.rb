class Category < ActiveHash::Base
  #
  #
  #
  field :accept_to_update, default: true
  self.data =
    [
     ### senior
     {
       name: "MEN",
       isu_bio_url: "http://www.isuresults.com/bios/fsbiosmen.htm",
       abbr: "M",
     },
     {
       name: "LADIES",
       isu_bio_url: "http://www.isuresults.com/bios/fsbiosladies.htm",
       abbr: "L",
     },
     {
       name: "PAIRS",
       isu_bio_url: "http://www.isuresults.com/bios/fsbiospairs.htm",
       abbr: "P",
     },
     {
       name: "ICE DANCE",
       isu_bio_url: "http://www.isuresults.com/bios/fsbiosicedancing.htm",
       abbr: "D",
     },
     #### junior
     {
       name: "JUNIOR MEN",
       abbr: "JM",
     },
     {
       name: "JUNIOR LADIES",
       abbr: "JL",
     },
     {
       name: "JUNIOR PAIRS",
       abbr: "JP",
     },
     {
       name: "JUNIOR ICE DANCE",
       abbr: "JD",
     },
    ]

  def update_skaters
    parser = Parser::SkaterParser.new
    ActiveRecord::Base.transaction do
      parser.parse_skaters(name, isu_bio_url).each do |hash|
        Skater.find_or_create_by(isu_number: hash[:isu_number]) do |skater|
          skater.update!(hash)
        end
      end
    end  # transaction
  end
    
  class << self
    ## class methods
    def accept!(categories)
      all.map {|c| c.accept_to_update = false }     # disable all once and..
      categories = [categories].flatten.map(&:to_s) # set true on the specified categories
      where(name: categories).map {|item| item.accept_to_update = true }
    end
    def accept?(category)
      where(accept_to_update: true, name: category.to_s).present?
    end
    def update_skaters
      all.select(&:isu_bio_url).map(&:update_skaters)
    end
  end ## self
end
