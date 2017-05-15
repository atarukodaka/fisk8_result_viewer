module FilterModules
  extend ActiveSupport::Concern

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
    
    scope :filter, ->(filters, parameters) {
      conditions = nil
      create_arel_tables_by_filters(filters, parameters).each do |arel|
        conditions = (conditions.nil?) ? arel : conditions.and(arel)
      end
      where(conditions)
    }

    class << self

      def select_options(key)
        @_select_options ||= {}
        return @_select_options[key] if @_select_options[key]
        @_select_options[key] = pluck(key).uniq.sort.unshift(nil)
      end

      def _parse_compare(text)
        if text =~ /^ *([\d\.]+) *$/
          method = :eq; value = $1.to_f
        else
          text =~ %r{^ *([=<>]+) *([\d\.]+) *$}
          method =
            case $1
            when '='; :eq
            when '>'; :gt
            when '>='; :gteq
            when '<'; :lt
            when '<='; :lteq
            else; nil
            end
          value = $2.to_f
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
    end
  end # included
end #module FilterModules
