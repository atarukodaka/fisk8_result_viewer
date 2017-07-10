class Category < ActiveHash::Base
  self.data =
    [
     ### senior
     {
       name: "MEN",
       segments: { short: "SHORT PROGRAM", free: "FREE SKATING" },
       isu_bio_url: "http://www.isuresults.com/bios/fsbiosmen.htm",
       senior: true,
     },
     {
       name: "LADIES",
       isu_bio_url: "http://www.isuresults.com/bios/fsbiosladies.htm",
       segments: { short: "SHORT PROGRAM", free: "FREE SKATING" },
       senior: true,
     },
     {
       name: "PAIRS",
       isu_bio_url: "http://www.isuresults.com/bios/fsbiospairs.htm",
       segments: { short: "SHORT PROGRAM", free: "FREE SKATING" },
       senior: true,
     },
     {
       name: "ICE DANCE",
       isu_bio_url: "http://www.isuresults.com/bios/fsbiosicedancing.htm",
       segments: { short: "SHORT DANCE", free: "FREE DANCE" },
       senior: true,
     },
     #### junior
     {
       name: "JUNIOR MEN",
       segments: { short: "SHORT PROGRAM", free: "FREE SKATING" },
     },
     {
       name: "JUNIOR LADIES",
       segments: { short: "SHORT PROGRAM", free: "FREE SKATING" },
     },
     {
       name: "JUNIOR PAIRS",
       segments: { short: "SHORT PROGRAM", free: "FREE SKATING" },
     },
     {
       name: "JUNIOR ICE DANCE",
       segments: { short: "SHORT DANCE", free: "FREE DANCE" },
     },
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
