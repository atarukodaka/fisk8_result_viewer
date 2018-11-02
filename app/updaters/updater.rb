module SkaterFinder
  using StringToModel

  def find_or_create_skater(item)
    corrected_skater_name = SkaterNameCorrection.correct(item[:skater_name])
    skater = (Skater.find_by(isu_number: item[:isu_number]) if item[:isu_number].present?) ||
             Skater.find_by(name: corrected_skater_name)

    skater || Skater.create! do |sk|
      category_type = item[:category].to_category.category_type
      sk.attributes = {
        isu_number: item[:isu_number],
        name: corrected_skater_name,
        nation: item[:skater_nation],
        category_type: category_type,
      }
    end
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
