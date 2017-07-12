class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    def uniq_list(key)
      @_list_cache ||= {}
      @_list_cache[key] ||= distinct.pluck(key).compact
    end
  end
end
