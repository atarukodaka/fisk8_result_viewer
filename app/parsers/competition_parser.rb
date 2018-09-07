module CompetitionParser
  DEFAULT_PARSER = :isu_generic
  class << self
    def create_parser(parser_type = nil)
      parser_type ||= DEFAULT_PARSER
      begin
        "CompetitionParser::#{parser_type.to_s.camelize}".constantize.new
      rescue NameError => e
        raise "NameError: parser_type '#{parser_type}' not registered"
      end
    end
  end
end

