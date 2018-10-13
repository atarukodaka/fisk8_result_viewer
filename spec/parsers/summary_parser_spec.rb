require 'rails_helper'

RSpec.describe CompetitionParser::SummaryParser do
  describe 'wc2018' do
    let(:site_url) { 'http://www.isuresults.com/results/season1718/wc2018/' }
    let(:summary) {  CompetitionParser::SummaryParser.new.parse(site_url) }
    let(:category_result_url) { 'http://www.isuresults.com/results/season1718/wc2018/CAT001RS.HTM' }
    let(:segment_result_url) { 'http://www.isuresults.com/results/season1718/wc2018/SEG001.HTM' }
    it {
      expect(summary[:country]).to eq('ITA')
      expect(summary.start_date).to eq(Date.new(2018, 3, 21))
      expect(summary.season.to_s).to eq('2017-18')
      expect(summary.category_result_url('MEN')).to eq(category_result_url)
      expect(summary[:segment_results].first[:result_url]).to eq(segment_result_url)
    }
  end

  describe 'wtt2017' do
    let(:site_url) { 'https://www.jsfresults.com/intl/2016-2017/wtt/' }
    let(:result_url) { 'https://www.jsfresults.com/intl/2016-2017/wtt/data0103.htm' }
    it {
      mod = CompetitionParser::SummaryParser::Extension::Wtt2017
      parser_class = CompetitionParser::SummaryParser.incorporate(:wtt2017)
      expect(parser_class.ancestors.include?(mod)).to be true

      summary = parser_class.new(verbose: false).parse(site_url)
      expect(summary.class).to eq(CompetitionParser::SummaryParser::Summary)
      expect(summary[:segment_results].first[:result_url]).to eq(result_url)
    }
  end
end
