module AsRanking
  refine Integer do
    def as_ranking
      (self == 0) ? "-" : "%d" % [self]
    end
  end
  refine Fixnum do
    def as_ranking
      (self == 0) ? "-" : "%d" % [self]
    end
  end
  refine NilClass do
    def as_ranking
      "-"
    end
  end
end

