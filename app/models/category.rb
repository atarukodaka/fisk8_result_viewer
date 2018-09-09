class Category < ActiveHash::Base
  field :accept_to_update, default: true

  self.data =
    [
     ### senior
     {
       name: "MEN",
       isu_bio_url: "http://www.isuresults.com/bios/fsbiosmen.htm",
       abbr: "SM",
     },
     {
       name: "LADIES",
       isu_bio_url: "http://www.isuresults.com/bios/fsbiosladies.htm",
       abbr: "SL",
     },
     {
       name: "PAIRS",
       isu_bio_url: "http://www.isuresults.com/bios/fsbiospairs.htm",
       abbr: "SP",
     },
     {
       name: "ICE DANCE",
       isu_bio_url: "http://www.isuresults.com/bios/fsbiosicedancing.htm",
       abbr: "SD",
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
     #### TEAM
     {
       name: "TEAM MEN",
       abbr: "TM",
     },
     {
       name: "TEAM LADIES",
       abbr: "TL",
     },
     {
       name: "TEAM PAIRS",
       abbr: "TP",
     },
     {
       name: "TEAM ICE DANCE",
       abbr: "TD",
     },
    ]

  ################
=begin
  class << self
    ## class methods
    def accept!(categories)
      all.map {|c| c.accept_to_update = false }     # disable all once and..
      categories = [categories].flatten.map(&:to_s) # set true on the specified categories
      where(name: categories).map {|item| item.accept_to_update = true }
    end
    def accept_all
      all.map {|item| item.accept_to_update = true}
    end
    def accept?(category)
      where(accept_to_update: true, name: category.to_s).present?
    end
  end ## self
=end
end
