module FilterModules
  extend ActiveSupport::Concern
  
  included do
#    scope :with_score, ->{ joins(:score) }
#    scope :with_skater, ->{ joins(:skater) }

=begin
    scope :filter, ->(arel_tables){
      cond = nil
      arel_tables.each do |arel|
        cond = (cond.nil?) ? arel : cond.and(arel)
      end
      where(cond)
    }
=end
  end ## included
end ## FilterModules



