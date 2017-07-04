class ParsersController < ApplicationController
  def index
  end
    
  def competition
    url = params[:url]
    parser_type = params[:parser_type].presence || :isu_generic
    parser = Parsers.get_parser(parser_type.to_sym)
    
    summary = Adaptor::CompetitionAdaptor.new(parser.parse(:competition, url))
    
    render locals: { summary: summary, parser: parser }
  end
  def scores
    url = params[:url]
    parser = Parsers.get_parser(:isu_generic)
    scores = parser.parse(:score, url)

    render locals: {scores: scores}
  end
  
end
