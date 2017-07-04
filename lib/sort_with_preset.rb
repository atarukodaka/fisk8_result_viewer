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

