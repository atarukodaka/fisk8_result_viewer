class IndexFilter
  def filters
    @_filters ||= {}
  end

  def hname(key, model: nil)
    model ||= self.class.to_s.sub(/Filter$/, '').classify.constantize
    model.human_attribute_name(key)
  end
end
