module FilterModules
  extend ActiveSupport::Concern
  
  included do
    scope :with_score, ->{ joins(:score) }
    scope :with_skater, ->{ joins(:skater) }
    scope :with_competition, ->{ joins(:competition) }

    scope :filter, ->(arel_tables){
      cond = nil
      arel_tables.each do |arel|
        cond = (cond.nil?) ? arel : cond.and(arel)
      end
      where(cond)
    }
  end ## included
end ## FilterModules



