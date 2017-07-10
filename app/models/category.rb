class Category < ActiveHash::Base
  field :accept_to_update, default: true
  field :segments, default: { short: "SHORT PROGRAM", free: "FREE SKATING"}
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
       segments: { short: "SHORT DANCE", free: "FREE DANCE" },
       senior: true,
     },
     #### junior
     { name: "JUNIOR MEN"},
     { name: "JUNIOR LADIES"},
     { name: "JUNIOR PAIRS"},
     { name: "JUNIOR ICE DANCE"},
    ]
  class << self
    ## scope
    def senior
      #self.all.select {|cat| cat.senior }
      self.where(senior: true)
    end
    def senior_categories
      self.senior.map(&:name)
    end

    ## class methods
    def accept_to_update(categories)
      Category.all.map {|c| c.accept_to_update = false }
      [categories].flatten.each do |category|
        item = find_by(name: category.to_s) || next
        item.accept_to_update = true
      end
    end
  end
end
