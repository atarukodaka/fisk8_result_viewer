module SelectOptions
  extend ActiveSupport::Concern

  class_methods do
    def select_options(key)
      pluck(key).compact.uniq.sort
    end

    def create_from_hash(hash, *args)
      keys = self.column_names.map(&:to_sym).reject {|k| k == self.primary_key.to_sym}
      create(hash.slice(*keys), *args) do |model|
        yield model if block_given?
      end
    end
  end
  
end

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  include SelectOptions
  
  #scope :matches, ->(type, v) { where("#{type} like ? ", "%#{v}%") }
end
