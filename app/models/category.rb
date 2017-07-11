class Category < ActiveHash::Base
  field :accept_to_update, default: true
  self.data =
    [
     ### senior
     {
       name: "MEN",
       isu_bio_url: "http://www.isuresults.com/bios/fsbiosmen.htm",
       senior: true,
     },
     {
       name: "LADIES",
       isu_bio_url: "http://www.isuresults.com/bios/fsbiosladies.htm",
       senior: true,
     },
     {
       name: "PAIRS",
       isu_bio_url: "http://www.isuresults.com/bios/fsbiospairs.htm",
       senior: true,
     },
     {
       name: "ICE DANCE",
       isu_bio_url: "http://www.isuresults.com/bios/fsbiosicedancing.htm",
       senior: true,
     },
     #### junior
     { name: "JUNIOR MEN"},
     { name: "JUNIOR LADIES"},
     { name: "JUNIOR PAIRS"},
     { name: "JUNIOR ICE DANCE"},
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
    ## like scope
    def senior
      #self.all.select {|cat| cat.senior }
      self.where(senior: true)
    end
    ## class methods
    def senior_categories
      self.senior.map(&:name)
    end

    def accept!(categories)
      all.map {|c| c.accept_to_update = false }   # disable all once and..
      categories = [categories].flatten.map(&:to_s)
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
