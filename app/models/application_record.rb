class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    def uniq_list(key)
      @_list_cache ||= {}
      @_list_cache[key] ||= distinct.pluck(key).compact
    end
    def searching_arel_table_node(table_column, sv, operator: :eq)
      at = arel_table[table_column]
      case operator
      when :eq, :lt, :lteq, :gt, :gteq
        at.send(operator, sv)
      else
        at.matches("%#{sv}%")
      end
    end
    
=begin    
    def arel_table_by_operator(key, operator_str, value)
      #operators = {'=' => :eq, '>' => :gt, '>=' => :gteq,
      #<' => :lt, '<=' => :lteq}
      #operator = operators[operator_str] || :eq
      operators = [:eq, :gt, :gteq, :lt, :lteq]
      operator = (operators.include?(operator_str.to_sym)) ? operator_str : :eq

      arel_table[key].send(operator, value.to_f)
    end
=end
  end


end
