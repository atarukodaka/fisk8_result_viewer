=begin
module SelectOptions
  extend ActiveSupport::Concern

  class_methods do
    def select_options(key)
      @_options_cache ||= {}
      @_options_cache[key] ||= distinct.pluck(key).compact
    end

    def create_from_hash(hash, *args)
      keys = self.column_names.map(&:to_sym).reject {|k| k == self.primary_key.to_sym}
      create(hash.slice(*keys), *args) do |model|
        yield model if block_given?
      end
    end
  end  
end
=end
################################################################

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  #include SelectOptions
  class << self
    def uniq_list(key)
      @_list_cache ||= {}
      @_list_cache[key] ||= distinct.pluck(key).compact
    end
  end
  
=begin
  def decorate_if(flag)
    (flag) ? decorate : self
  end

  class << self
    def findor_by(**hash)
      arel = nil
      hash.each do |k, v|
        this_arel = arel_table[k].eq(v)
        if arel
          arel = arel.or(this_arel)
        else
          arel = this_arel
        end
      end
      where(arel).first
    end

    def findor_or_create_by(**hash)
      findor_by(hash) || create(hash) do |skater|
        yield skater if block_given?
      end
    end
  end
=end
end
