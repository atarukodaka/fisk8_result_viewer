module StringToModel
  refine String do
    def to_category
      Category.find_by!(name: self)
    end

    def to_segment
      Segment.find_by!(name: self)
    end
  end

  refine NilClass do
    def to_category
      nil
    end

    def to_segment
      nil
    end
  end
end
