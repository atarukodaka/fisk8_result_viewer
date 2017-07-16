module AsScore
  refine Float do
    def as_score
      (self == 0) ? "-" : "%.2f" % [self]
    end
  end
  refine Fixnum do
    def as_score
      (self == 0) ? "-" : "%.2f" % [self]
    end
  end
  refine NilClass do
    def as_score
      "-"
    end
  end
end
