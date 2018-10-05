module AsScore
  refine Float do
    def as_score
      (self.zero?) ? '-' : '%.2f' % [self]
    end
  end
  refine Integer do
    def as_score
      (self.zero?) ? '-' : '%.2f' % [self]
    end
  end
  refine NilClass do
    def as_score
      '-'
    end
  end
end
