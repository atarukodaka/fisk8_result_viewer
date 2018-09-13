class Category < ApplicationRecord
  has_many :category_results
  has_many :segment_results
  has_many :scores
end

__END__
=begin
class Category < ActiveHash::Base
  include ActiveHash::Associations

  has_many :category_results
  has_many :segment_results
  has_many :scores

  #field :accept_to_update, default: true

  self.data =
    [
     ### senior
     {
       name: "MEN",
       isu_bio_url: "http://www.isuresults.com/bios/fsbiosmen.htm",
       abbr: "SM",
       seniority: "senior",
     },
     {
       name: "LADIES",
       isu_bio_url: "http://www.isuresults.com/bios/fsbiosladies.htm",
       abbr: "SL",
       seniority: "senior",
     },
     {
       name: "PAIRS",
       isu_bio_url: "http://www.isuresults.com/bios/fsbiospairs.htm",
       abbr: "SP",
       seniority: "senior",
     },
     {
       name: "ICE DANCE",
       isu_bio_url: "http://www.isuresults.com/bios/fsbiosicedancing.htm",
       abbr: "SD",
       seniority: "senior",
     },
     #### junior
     {
       name: "JUNIOR MEN",
       abbr: "JM",
       seniority: "junior",
     },
     {
       name: "JUNIOR LADIES",
       abbr: "JL",
       seniority: "junior",
     },
     {
       name: "JUNIOR PAIRS",
       abbr: "JP",
       seniority: "junior",
     },
     {
       name: "JUNIOR ICE DANCE",
       abbr: "JD",
       seniority: "junior",
     },
     #### TEAM
     {
       name: "TEAM MEN",
       abbr: "TM",
       seniority: "senior",
     },
     {
       name: "TEAM LADIES",
       abbr: "TL",
       seniority: "senior",
     },
     {
       name: "TEAM PAIRS",
       abbr: "TP",
       seniority: "senior",
     },
     {
       name: "TEAM ICE DANCE",
       abbr: "TD",
       seniority: "senior",
     },
     #### UNKNOWN
     {
       name: "UNKNOWN",
       abbr: "UK",
       seniority: "unknown",
     }
    ]
=end
  def men?
    self.name =~ /MEN/
  end

  def senior?
    self.seniority == "seinor"
  end

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

