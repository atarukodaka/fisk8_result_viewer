module CategorySegmentSelector
  refine Array do
    def categories
      map { |d| d[:category] }.uniq.map { |d| Category.find_by(name: d) }
    end

    def segments
      map { |d| d[:segment] }.uniq.map { |d| Segment.find_by(name: d) }
    end

    def select_category(category)
      select { |d| d[:category] == category.name }
    end

    def select_category_segment(category, segment)
      select { |d| d[:category] == category.name && d[:segment] == segment.name }
    end
  end
end
