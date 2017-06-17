module Fisk8ResultViewer
  module Adaptor
    class CategoryResultAdaptor
        def initialize(hash)
          cr = ::CategoryResult.new(hash)
          cr.skater_name = ::Skater.correct_name(cr.skater_name)
          cr.skater = ::Skater.find_or_initialize_by_isu_number_or_name(cr.isu_number, cr.skater_name) do |sk|
            sk.category = cr.category.seniorize
            sk.nation = cr.nation
          end
          cr.skater_name = cr.skater.name
          @model = cr
        end
        def to_model
          @model
        end
      end
  end
end
