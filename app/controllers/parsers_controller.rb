class ParsersController < ApplicationController
=begin
  def competition
    site_url = params['url']
    date_format = nil
    parser_type = nil
    competition = CompetitionParser.new.parse(site_url, parser_type: parser_type, date_format: date_format)
    render :competition, locals: { competition: competition}
  end
=end
  def scores
    scores = CompetitionParser::ScoreParser.new.parse(params['url'])
    render :scores, locals: { scores: scores }
  end
end
