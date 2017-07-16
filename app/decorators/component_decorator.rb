class ComponentDecorator < ElementDecorator
  using AsScore
  def value
    model.value.as_score
  end
end
