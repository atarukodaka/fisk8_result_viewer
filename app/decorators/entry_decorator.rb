
class EntryDecorator < Draper::Decorator
  include ApplicationHelper
  delegate_all

  class << self
    using AsRanking
    using AsScore
    
    def display_as(type, keys)
      keys.each do |key|
        self.send(:define_method, key) do
          case type
          when :ranking
            model[key].to_f.as_ranking
          when :score
            model[key].as_score
          end
        end
      end
    end ## def
  end
  
  self.display_as(:ranking, [:ranking])
  self.display_as(:score, [:tss, :tes, :pcs, :deductions, :base_value, :value, :goe])
end
