module Parsers
  @registered = {}
  class << self
    attr_reader :registered
    def register(key, klass)
      @registered[key] = klass
    end
    
    def get_parser(type)
      #@registered[type].const_get(roll.to_s.camelize.to_sym).const_get(:Parser).new
      #@registered[type].const_get("#{roll.to_s.camelize}Parser").new
      @registered[type].new
    end
  end
end


## require all rb files under ./parsers
Dir[File.expand_path('../parsers', __FILE__) << '/*.rb'].each do |file|
  require file
end

# TODO
#Parsers::IsuGeneric
