class EntryDecorator < Draper::Decorator
  include ApplicationHelper
  delegate_all

  class << self
    def display_as(type, keys)
      keys.each do |key|
        self.send(:define_method, key) do
          case type
          when :ranking
            as_ranking(model[key])
          when :score
            as_score(model[key])
          end
        end
      end
    end ## def
  end
  
  self.display_as(:ranking, [:ranking])
  self.display_as(:score, [:tss, :tes, :pcs, :deductions, :base_value, :value, :goe])
end
