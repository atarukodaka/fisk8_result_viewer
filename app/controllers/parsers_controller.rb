class ParsersController < ApplicationController
  def index
  end
    
  def competition
    url = params[:url]
    parser_type = params[:parser_type].presence || :isu_generic
    render locals: { parser_type: parser_type, url: url }
  end
  def scores
    url = params[:url]
    parser = Parser::ScoreParser.new
    scores = parser.parse(url)

    render locals: {scores: scores}
  end
  
end
