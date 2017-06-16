module Fisk8ResultViewer
  class Parser
    def parse(type, url)
      self.class.const_get("#{type.to_s.camelize}Parser").new.parse(url)
      #"#{type.to_s.camelize}Parser".constantize.new.parse(url)
      #object.const_get("#{type.to_s.camelize}Parser").new.parse(url)
    end
  end
end
