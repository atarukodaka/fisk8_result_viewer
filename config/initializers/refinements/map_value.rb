module MapValue
  refine Array do
    def map_value(key)
      map { |d| d[key] }
    end
  end
end
