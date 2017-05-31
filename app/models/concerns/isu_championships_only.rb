module IsuChampionshipsOnly
  extend ActiveSupport::Concern

  included do
    scope :isu_championships_only, -> { with_competition.where("competitions.isu_championships" => true) }
    scope :isu_championships_only_if, -> (flag){ isu_championships_only if flag}
  end
end  
