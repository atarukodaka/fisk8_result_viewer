class EntryDecorator < Draper::Decorator
  include ApplicationHelper
  delegate_all

  def no; end
  class << self
    using AsScore
    using AsRanking

    def decorate_as_score(*columns)
      [*columns].flatten.each do |column|
        define_method(column.to_sym) do
          model.send(column.to_sym).as_score
        end
      end
    end

    def decorate_as_ranking(*columns)
      [*columns].flatten.each do |column|
        define_method(column.to_sym) do
          model.send(column.to_sym).as_ranking
        end
      end
    end
  end ## class << self
end
