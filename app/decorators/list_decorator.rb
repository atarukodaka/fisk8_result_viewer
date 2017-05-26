class ListDecorator < Draper::Decorator
  include ApplicationHelper
  delegate_all

  class << self
      def headers
      {
        base_value: "BV",
        number: "#",
      }
    end

    def display_as(type, keys)
      keys.each do |key|
        self.send(:define_method, key) do
          case type
          when :ranking
            as_ranking(model[key])
          when :score
            as_score(model[key])
          else
            raise
          end
        end
      end
    end ## def
  end
  
  self.display_as(:ranking, [:ranking])
  self.display_as(:score, [:tss, :tes, :pcs, :deductions, :base_value, :value, :goe])
  
=begin
 class_attribute :filter_keys
  
  class << self
    def set_filter_keys(keys)

      self.filter_keys = keys
      keys.each do |key|
        unless self.instance_methods.include?(key)
          self.send(:define_method, key) {
            filter_index(key)
          }
        end
      end
    end
  end
=end
  def filter_index(key)
    h.link_to_index(model[key], parameters: h.params.permit(filter_keys).merge(key => model[key]))
  end
end
