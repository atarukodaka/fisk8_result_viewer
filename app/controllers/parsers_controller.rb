class ParsersController < ApplicationController
  def index
    if Rails.env.development?
      render
    else
      render plain: "works for only development"
    end
  end
    
  def competition
    unless Rails.env.development?
      render plain: "works for only development", layout: :application
    else
      url = params[:url]
      parser_type = params[:parser_type].presence || :isu_generic
      render locals: { parser_type: parser_type, url: url }
    end
  end
  def scores
    unless Rails.env.development?
      render plain: "works for only development", layout: :application      
    else
      url = params[:url]
      parser = Parser::ScoreParser.new
      scores = parser.parse(url)
    
      render locals: {scores: scores}
    end
  end
  
end
