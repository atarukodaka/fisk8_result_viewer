class Parsers
  class << self
    DEFAULT_PARSER_TYPE = :isu_generic
    
    def parser(roll, type = nil)
      type ||= DEFAULT_PARSER_TYPE
      klass = "Parsers::#{type.to_s.camelize}::#{roll.to_s.camelize}Parser".constantize
      klass.new
    end
  end
end
