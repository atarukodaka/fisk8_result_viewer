class CompetitionParser
  DEFAULT_PARSER = :isu_generic
=begin
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
=end
  ################
  def initialize(type = nil)
    type ||= DEFAULT_PARSER
    type_classname = type.to_s.camelize
    @parser = {
      summary: "CompetitionParser::#{type_classname}::SummaryParser".constantize.new,
      category_result: "CompetitionParser::#{type_classname}::CategoryResultParser".constantize.new,
      segment_result: "CompetitionParser::#{type_classname}::SegmentResultParser".constantize.new,
      score: "CompetitionParser::#{type_classname}::ScoreParser".constantize.new,
    }
  end
  ################
  def parse(type, url, *args)
    raise "no such parser type: #{type}" if @parser.has_key?(type.to_s)
    
    if args.blank?
      @parser[type].parse(url)
    else
      @parser[type].parse(url, *args)
    end
  end
end

