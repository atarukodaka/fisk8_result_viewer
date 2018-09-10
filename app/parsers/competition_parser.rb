class CompetitionParser
  DEFAULT_PARSER = :isu_generic
=begin
  ################
  def initialize(parser_type = nil, verbose: false)
    parser_type ||= DEFAULT_PARSER
    parser_type_classname = parser_type.to_s.camelize
    @parsers = {}
    [:summary, :category_result, :segment_result, :score].each do |subject|
      begin
        @parsers[subject] =
          "CompetitionParser::#{parser_type_classname}::#{subject.to_s.camelize}Parser".constantize.new(verbose: verbose)
      rescue NameError => e
        raise "NameError: parser_type '#{parser_type}' not registered"
      end
    end
  end
  ################
  def parse(subject, url, *args)
    raise "no such parser subject: #{subject}" if @parsers.has_key?(subject.to_s)

    @parsers[subject].parse(*[url, args].flatten)
  end
=end
end

