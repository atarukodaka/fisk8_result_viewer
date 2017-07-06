class Manipulator
  def manipulate(collection)
    collection
  end
end

class FilterManipulator < Manipulator
  attr_reader :filters, :params
  def initialize(filters = nil, params = nil)
    @filters = filters || {}
    @params = params || {}
  end

  def manipulate(collection)
    col = super(collection)
    # input params
    filters.each do |key, pr|
      v = params[key]
      col = pr.call(col, v) if v.present? && pr
    end
    col
  end
end
