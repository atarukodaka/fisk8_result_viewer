require 'rails_helper'
require 'fisk8viewer'

RSpec.configure do |c|
  unless ENV['run_parser']
    c.exclusion_filter = {parser: true}
  end
end

describe 'parser', parser: true do
  describe 'score' do
    subject (:score){
      filename = "pdf/wtt2013_Pairs_SP_P_Scores.pdf"
      parser = Fisk8Viewer::Parser::ScoreParser.new
      url = "http://www.isuresults.com/results/season1617/gpjpn2016/gpjpn2016_Men_SP_Scores.pdf"
      hash = parser.parse(url)
      score = hash.select {|elem| elem[:ranking] == 1}.first
    }
    it { expect(score[:skater_name]).to eq('Yuzuru HANYU') }
    it { expect(score[:nation]).to eq('JPN') }
    it { expect(score[:elements][0][:element]).to eq('4Lo') }
    it { expect(score[:elements][0][:base_value]).to eq(12.0) }
    it { expect(score[:elements][0][:value]).to eq(9.37) }
    it { expect(score[:components][0][:component]).to eq('Skating Skills') }
    it { expect(score[:components][0][:value]).to eq(9.39) }

  end

  describe 'competition summary' do
    subject (:parsed){
      url = 'http://www.isuresults.com/results/season1617/gpjpn2016/'
      parser = Fisk8Viewer::Parser::CompetitionSummaryParser.new
      parsed = Fisk8Viewer::CompetitionSummary.new(parser.parse(url))
    }
    its(:categories) { should eq(["ICE DANCE", "LADIES", "MEN", "PAIRS"]) }
    it { expect(parsed.segments('MEN')).to eq(['SHORT PROGRAM', 'FREE SKATING']) }
    it { expect(parsed.result_url('MEN')).to eq('http://www.isuresults.com/results/season1617/gpjpn2016/CAT001RS.HTM') }
    it { expect(parsed.score_url('MEN', 'SHORT PROGRAM')).to eq('http://www.isuresults.com/results/season1617/gpjpn2016/gpjpn2016_Men_SP_Scores.pdf') }
    it { expect(parsed.starting_time('MEN', 'SHORT PROGRAM')).to eq(Time.zone.parse('2016/11/25 19:11:30')) }
  end

  describe 'competition category result' do
    subject (:result) {
      url = 'http://www.isuresults.com/results/season1617/gpjpn2016/CAT001RS.HTM'
      parser = Fisk8Viewer::Parser::CategoryResultParser.new
      parser.parse(url).select {|e| e[:ranking] == 1 }.first
    }

    it { expect(result[:skater_name]).to eq('Yuzuru HANYU') }
    it { expect(result[:nation]).to eq('JPN') }
    it { expect(result[:points]).to eq(301.47) }

  end


  describe 'score' do
    subject (:score){
      filename = "pdf/wtt2013_Pairs_SP_P_Scores.pdf"
      parser = Fisk8Viewer::Parser::ScoreParser.new
      url = "http://www.isuresults.com/results/season1617/gpjpn2016/gpjpn2016_Men_SP_Scores.pdf"
      hash = parser.parse(url)
      score = hash.select {|elem| elem[:ranking] == 1}.first
    }
    it { expect(score[:skater_name]).to eq('Yuzuru HANYU') }
    it { expect(score[:nation]).to eq('JPN') }
    it { expect(score[:elements][0][:element]).to eq('4Lo') }
    it { expect(score[:elements][0][:base_value]).to eq(12.0) }
    it { expect(score[:elements][0][:value]).to eq(9.37) }
    it { expect(score[:components][0][:component]).to eq('Skating Skills') }
    it { expect(score[:components][0][:value]).to eq(9.39) }

  end

  describe 'competition summary' do
    subject (:parsed){
      url = 'http://www.isuresults.com/results/season1617/gpjpn2016/'
      parser = Fisk8Viewer::Parser::CompetitionSummaryParser.new
      Fisk8Viewer::CompetitionSummary.new(parser.parse(url))
    }
    its(:categories) { should eq(["ICE DANCE", "LADIES", "MEN", "PAIRS"]) }
    it { expect(parsed.segments('MEN')).to eq(['SHORT PROGRAM', 'FREE SKATING']) }
    it { expect(parsed.result_url('MEN')).to eq('http://www.isuresults.com/results/season1617/gpjpn2016/CAT001RS.HTM') }
    it { expect(parsed.score_url('MEN', 'SHORT PROGRAM')).to eq('http://www.isuresults.com/results/season1617/gpjpn2016/gpjpn2016_Men_SP_Scores.pdf') }
    it { expect(parsed.starting_time('MEN', 'SHORT PROGRAM')).to eq(Time.zone.parse('2016/11/25 19:11:30')) }
  end

  describe 'competition category result' do
    subject (:result) {
      url = 'http://www.isuresults.com/results/season1617/gpjpn2016/CAT001RS.HTM'
      parser = Fisk8Viewer::Parser::CategoryResultParser.new
      parser.parse(url).select {|e| e[:ranking] == 1 }.first
    }
    it { expect(result[:skater_name]).to eq('Yuzuru HANYU') }
    it { expect(result[:nation]).to eq('JPN') }
    it { expect(result[:points]).to eq(301.47) }

  end
end
