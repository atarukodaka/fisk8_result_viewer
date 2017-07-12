class CategorySegment < ActiveHash::Base
  include Draper::Decoratable
  
  fields :competition, :category, :short, :free

  class << self
    def decorator_class
      CategorySegmentDecorator
    end
  end
end
