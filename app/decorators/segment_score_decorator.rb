class SegmentScoreDecorator < ScoreDecorator
  class << self
    def column_names
      [:ranking, :skater_name, :nation, :starting_number, :tss, :tes, :pcs, :deductions, :elements_summary, :components_summary]
    end
  end
  def elements_summary
    model.elements.map(&:name).join('/')
  end
  def components_summary
    model.components.map(&:value).join('/')
  end

end
