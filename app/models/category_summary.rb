class CategorySummary < ActiveHash::Base
  include Draper::Decoratable
  
  fields :competition, :category, :short, :free

  class << self
    def decorator_class
      CategorySummaryDecorator
    end
  end
end
