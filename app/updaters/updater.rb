module SkaterFinder
  using StringToModel

  def find_or_create_skater(skater_name:, isu_number: nil, skater_nation: nil, category:)
  #def find_or_create_skater(name:, isu_number:, nation:, category_type: )
    if isu_number.present?
      Skater.find_by(isu_number: isu_number)
    else
      corrected_name = SkaterNameCorrection.correct(skater_name)
      Skater.find_or_create_by(name: corrected_name) do |skater|
        skater.attributes = {
          isu_number: isu_number,
          nation: skater_nation,
          category_type: category.to_category.category_type,
        }
      end
    end
=begin
    skater = (Skater.find_by(isu_number: isu_number) if isu_number.present?) ||
             Skater.find_by(name: corrected_skater_name) ||
             Skater.create! do |sk|
               sk.attributes = {
                 isu_number: isu_number,
                 name: corrected_skater_name,
                 nation: skater_nation,
                 category_type: category.to_category.category_type,
               }
    end
=end
  end
end

class Updater
  include SkaterFinder
  include DebugPrint

  attr_accessor :verbose

  def initialize(verbose: false)
    @verbose = verbose
  end
end
