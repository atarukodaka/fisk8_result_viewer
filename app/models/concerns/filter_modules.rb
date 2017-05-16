module FilterModules
  extend ActiveSupport::Concern
  
  class_methods do
    @@_select_options = {}   ## caching purpose
    @@_select_options_callback = {}
    
    def select_options(key)
      return @@_select_options[key] if @@_select_options[key]
      @@_select_options[key] =
        if cb = @@_select_options_callback[key]
          cb.call(key)
        else
          pluck(key).sort.uniq.unshift(nil)
        end
    end
    def register_select_options_callback(key, &func)
      @@_select_options_callback[key] = func
    end

    def _parse_compare(text)
      method = :eq; value = text.to_i
      if text =~ %r{^ *([=<>]+) *([\d\.\-]+) *$}
        value = $2.to_f
        method =
          case $1
          when '='; :eq
          when '>'; :gt
          when '>='; :gteq
          when '<'; :lt
          when '<='; :lteq
          end
      end
      {method: method, value: value}
    end
    def create_arel_tables_by_filters(filters, parameters)
      arel_tables = []
        filters.each do |key, hash|
        next if (value = parameters[key]).blank? || hash[:operator].nil?
        model = hash[:model] || self
        
        case hash[:operator]
        when :like, :match
          arel_tables << model.arel_table[key].matches("%#{value}%")
        when :eq, :is
          arel_tables << model.arel_table[key].eq(value)
        when :compare
          parsed = _parse_compare(value)
          logger.debug("#{value} parsed as '#{parsed[:method]}'")
          arel_tables << model.arel_table[key].method(parsed[:method]).call(parsed[:value]) if parsed[:method]
          
        end
      end
      arel_tables
    end
  end  ## class methods
  ################
  included do
    scope :select_by_keys, ->(headers){
      case headers
      when Hash
        str = headers.map {|table, keys|
          keys.map {|k| "#{table}.#{k.to_s}"}
        }.flatten.join(",")
        select(str)
      else
        raise   # to implement for Array
      end

    }
    scope :with_score, ->{ joins(:score) }
    scope :with_skater, ->{ join(:skater) }
    scope :with_competition, ->{ join(:competition) }
    
    scope :filter, ->(filters, parameters) {
      conditions = nil
      create_arel_tables_by_filters(filters, parameters).each do |arel|
        conditions = (conditions.nil?) ? arel : conditions.and(arel)
      end
      where(conditions)
    }
  end ## included
end #module FilterModules
