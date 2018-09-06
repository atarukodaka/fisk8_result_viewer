module CompetitionParser
  DEFAULT_PARSER = :isu_generic
  class << self
    def create_parser(parser_type = DEFAULT_PARSER)
      "CompetitionParser::#{parser_type.to_s.camelize}".constantize.new
    end
  end
end

