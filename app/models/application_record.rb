class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    def uniq_list(key)
      @_list_cache ||= {}
      @_list_cache[key] ||= distinct.pluck(key).compact
    end

    def arel_table_by_operator(key, operator_str, value)
      #operators = {'=' => :eq, '>' => :gt, '>=' => :gteq,
      #<' => :lt, '<=' => :lteq}
      #operator = operators[operator_str] || :eq
      operators = [:eq, :gt, :gteq, :lt, :lteq]
      operator = (operators.include?(operator_str.to_sym)) ? operator_str : :eq

      arel_table[key].send(operator, value.to_f)
    end
  end
end
