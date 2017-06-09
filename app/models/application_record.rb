module SelectOptions
  extend ActiveSupport::Concern

  class_methods do
    def select_options(key)
      pluck(key).compact.uniq.sort
    end
  end
  
end

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  include SelectOptions
  
  #scope :matches, ->(type, v) { where("#{type} like ? ", "%#{v}%") }
end
