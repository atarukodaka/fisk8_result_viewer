module SortWithPreset
  refine Array do
    def sort_with_preset(preset)
      preset_hash = preset.map {|v| [v, false]}.to_h
      to_sort = []
      self.each do |v|
        if preset.include?(v)
          preset_hash[v] = true
        else
          to_sort << v
        end
      end
      preset.select {|v| preset_hash[v]} + to_sort.sort
    end
  end
end

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

module AsScore
  refine Float do
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
