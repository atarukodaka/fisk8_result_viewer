class ParsersController < ApplicationController
=begin
  def competition
    site_url = params['url']
    parser_type = nil
    competition = CompetitionParser.new.parse(site_url, parser_type: parser_type)
    render :competition, locals: { competition: competition}
  end
=end
  def scores
    scores = CompetitionParser::ScoreParser.new.parse(params['url'])
    render :scores, locals: { scores: scores }
  end
end
