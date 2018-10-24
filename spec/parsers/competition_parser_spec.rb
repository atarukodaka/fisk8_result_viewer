require 'rails_helper'

RSpec.describe CompetitionParser do
  include HttpGet
  using AcceptCategories
  let(:site_url) { 'http://www.isuresults.com/results/season1617/wc2017/' }
  let(:parser) { CompetitionParser.new }

  describe 'categories' do
    let(:all_categories) { ['MEN', 'LADIES', 'PAIRS', 'ICE DANCE'] }
    let(:summary_table) { parser.parse_summary_table(get_url(site_url), base_url: site_url) }

    it {
      expect(summary_table.map { |d| d[:category] }.uniq).to eq(all_categories)
      expect(summary_table.accept_categories(nil).map { |d| d[:category] }.uniq).to eq(all_categories)
      expect(summary_table.accept_categories([]).map { |d| d[:category] }.uniq).to be_empty
      expect(summary_table.accept_categories(['MEN']).map { |d| d[:category] }.uniq).to eq(['MEN'])
    }
  end
end
