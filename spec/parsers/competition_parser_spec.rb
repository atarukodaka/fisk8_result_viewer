require 'rails_helper'

RSpec.describe CompetitionParser, vcr: true do
  include HttpGet
  #using AcceptCategories
  using MapValue
  let(:site_url) { 'http://www.isuresults.com/results/season1617/wc2017/' }
  let(:parser) { CompetitionParser.new }

=begin
  describe 'categories' do
    let(:all_categories) { ['MEN', 'LADIES', 'PAIRS', 'ICE DANCE'] }
    let(:invalid_category) { 'SYNCHRONIZED SKATING' }
    let(:summary_table) { parser.parse_summary_table(get_url(site_url), base_url: site_url) }

    it {
      expect(summary_table.map_value(:category).uniq).to eq(all_categories)
      expect(summary_table.accept_categories(nil).map_value(:category).uniq).to eq(all_categories)
      expect(summary_table.accept_categories([]).map_value(:category).uniq).to be_empty
      expect(summary_table.accept_categories(['MEN']).map_value(:category).uniq).to eq(['MEN'])
      expect(summary_table.accept_categories([invalid_category]).map_value(:category).uniq).to be_empty
    }
  end
=end
  describe 'summary_parser: join_url' do
    it {
      st_parser = CompetitionParser::SummaryTableParser.new
      base_url = 'http://www.foo.com/wc2017'
      expected_url = "#{base_url}/result.html"
      path = 'result.html'

      expect(st_parser.join_url(base_url.to_s, path)).to eq(expected_url)
      expect(st_parser.join_url("#{base_url}/", path)).to eq(expected_url)
      expect(st_parser.join_url("#{base_url}/index.html", path)).to eq(expected_url)
      expect(st_parser.join_url("#{base_url}/index.htm", path)).to eq(expected_url)
    }
  end

  ################
  context 'city, countery' do
    [['http://www.isuresults.com/results/gpusa2012/', 'Seattle / Kent, WA', 'USA'],
     ['http://www.fsatresults.com/ISUchallenger/indexISUCSAOFST2018.html', 'Bangkok', nil],
     ['http://www.isuresults.com/results/season1516/jgpusa2015/', 'Colorado Springs CO', 'USA']]
      .each do |url, city, country|
      it {
        page = get_url(url)
        data = parser.parse_city_country(page)
        expect(data).to eq([city, country])
      }
    end
  end

=begin
 describe 'synchronized' do
    let(:site_url) { 'http://www.figureskatingresults.fi/results/1314/FT2013/' }
    it {
      parser.parse(site_url)
    }
  end
=end
end
