class CategorySkipper
  def initialize(categories, excluding: nil)
    excluding_categories ||= []
    @categories_to_update = categories || Category.all.map(&:name).reject { |d| Array(excluding).include?(d) }
  end

  def skip?(category)
    !@categories_to_update.include?(category)
  end
end
