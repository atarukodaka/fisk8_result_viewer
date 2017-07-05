class Parser
  def parse(roll, url)
    begin
      self.class.const_get("#{roll.to_s.camelize}Parser").new.parse(url)
    rescue NameError
      raise "no such roll: #{roll}"
    end
  end


  def parse_competition(url)
    
  end

  def parse_category_result(url)
  end
  
end
