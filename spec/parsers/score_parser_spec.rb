require 'rails_helper'

RSpec.describe CompetitionParser::ScoreParser do
  describe "deduction reasons" do
    ## rank3 kolyada: falls: -4.00(3)
    let (:score_url) { 'http://www.isuresults.com/results/season1718/gprus2017/gprus2017_Men_FS_Scores.pdf' }
    let(:parser) { CompetitionParser::ScoreParser.new }
    let(:score) { parser.parse(score_url).find {|d| d[:ranking] == 3} }
    
    it {
      expect(score[:deductions]).to eq(-4.00)
      expect(score[:deduction_reasons]).to eq("Falls: -4.00 (3)")
    }
  end
end

