class Parser
=begin  
  def parse(roll, url)
    begin
      self.class.const_get("#{roll.to_s.camelize}Parser").new.parse(url)
    rescue NameError
      raise "no such roll: #{roll}"
    end
  end
=end
end
