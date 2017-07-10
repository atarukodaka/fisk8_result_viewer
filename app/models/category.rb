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
    def senior
      #self.all.select {|cat| cat.senior }
      self.where(senior: true)
    end
    def senior_categories
      self.senior.map(&:name)
    end
  end
end
