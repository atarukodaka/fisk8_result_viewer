class CompetitionParser
  class ParserBuilder
    class << self
      def build(parser_type = nil, verbose: false)
        parser_type ||= CompetitionParser::DEFAULT_PARSER
        parser_type_classname = parser_type.to_s.camelize
        parsers = {}
        [:summary, :category_result, :segment_result, :score, :panel].each do |subject|
          begin
            parsers[subject] =
              "CompetitionParser::#{parser_type_classname}::#{subject.to_s.camelize}Parser".constantize.new(verbose: verbose)
          rescue NameError => err
            raise "NameError: parser_type '#{parser_type}' not registered: #{err.message}"
          end
        end
        parsers
      end
    end
  end
end
