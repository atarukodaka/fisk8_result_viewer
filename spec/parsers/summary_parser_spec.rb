require 'rails_helper'

RSpec.describe CompetitionParser::SummaryParser do
  describe 'wc2018' do
    let(:site_url) { 'http://www.isuresults.com/results/season1718/wc2018/' }
    let(:summary) {  CompetitionParser::SummaryParser.new.parse(site_url) }
    it {
      expect(summary[:country] ).to eq('ITA')
      expect(summary[:time_schedule].start_date).to eq(Date.new(2018,3,21))
      expect(summary[:time_schedule].season.to_s).to eq('2017-18')
      expect(summary[:category_results].first[:result_url]).to eq('http://www.isuresults.com/results/season1718/wc2018/CAT001RS.HTM')
      expect(summary[:segment_results].first[:result_url]).to eq('http://www.isuresults.com/results/season1718/wc2018/SEG001.HTM')
    }
  end
end
