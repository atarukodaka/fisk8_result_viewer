module Seniorize
  refine String do
    def seniorize!
      gsub!(/^JUNIOR +/, '')
      self
    end
    def seniorize
      dup.seniorize!
    end
  end
end

