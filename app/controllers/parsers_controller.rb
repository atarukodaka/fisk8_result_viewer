class ParsersController < ApplicationController
  def index
    if Rails.env.production?
      render plain: "works for only development/test"
    else
      render
    end
  end
    
  def competition
    if Rails.env.production?
      render plain: "works for only development", layout: :application
    else
      url = params[:url]
      parser_type = params[:parser_type].presence || :isu_generic
      render locals: { parser_type: parser_type, url: url }
    end
  end
  def scores
    if Rails.env.production?
      render plain: "works for only development", layout: :application      
    else
      url = params[:url]
      parser = CompetitionParser::ScoreParser.new
      scores = parser.parse(url)
    
      render locals: {scores: scores}
    end
  end
  
end
