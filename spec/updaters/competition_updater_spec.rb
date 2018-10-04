require 'rails_helper'

RSpec.configure do |c|
  c.filter_run_excluding updater: true
end

RSpec.describe Competition, type: :competition_updater, updater: true do
  before { @updater = CompetitionUpdater.new }

  describe 'parser types:' do
    shared_examples :having_competition_with_url do
      its(:site_url) { is_expected.to eq(url) }
    end

    describe 'wc2017 with isu_generic' do
      let(:url) { 'http://www.isuresults.com/results/season1617/wc2017/' }
      subject { @updater.update_competition(url) }
      it_behaves_like :having_competition_with_url
    end
    describe 'jgpfra2010 with isu_generic for mdy_date type' do
      let(:url) { 'http://www.isuresults.com/results/jgpfra2010/' }
      let(:date_format) { '%m/%d/%Y' }
      subject { @updater.update_competition(url, categories: ['MEN'], date_format: date_format) }
      it_behaves_like :having_competition_with_url
    end

    describe 'wtt2017' do
      let(:url) { 'https://www.jsfresults.com/intl/2016-2017/wtt/' }
      subject { CompetitionUpdater.new(parser_type: :wtt2017).update_competition(url, categories: ['ICE DANCE']) }
      it_behaves_like :having_competition_with_url
    end

    describe 'owgteam' do
      let(:url) { 'http://www.isuresults.com/results/season1718/owg2018/' }
      subject(:competition) { @updater.update_competition(url, categories: ['TEAM MEN']) }
      it_behaves_like :having_competition_with_url
      # it { expect(competition.scores.where("category like ? ", "TEAM%").blank?).to be false }
      it { expect(competition.scores.includes(:category).references(:category).where('categories.name like ? ', 'TEAM%').blank?).to be false }
    end

    describe 'gpfra2015 - no free skating' do
      let(:url) { 'http://www.isuresults.com/results/season1516/gpfra2015/' }
      subject(:competition) { @updater.update_competition(url, categories: ['MEN']) }
      it_behaves_like :having_competition_with_url
    end

=begin
    describe 'aci' do   ## its nightmare
      let(:url) {'https://skatecanada.ca/event/2016-autumn-classic-international/' }
      subject { CompetitionUpdater.new(parser_type: :autumn_classic).update_competition(url) }
      it_behaves_like :having_competition_with_url
    end
=end
  end

  describe 'enable_judge_details' do
    it {
      url = 'http://www.isuresults.com/results/season1617/wc2017/'
      updater = CompetitionUpdater.new(enable_judge_details: true, verbose: false)

      updater.update_competition(url, categories: ['MEN'])
      expect(ElementJudgeDetail.count).to be > 0
      expect(ComponentJudgeDetail.count).to be > 0
    }
  end

  describe 'season from/to' do
    it {
      wc2014 = 'http://www.isuresults.com/results/wc2014/'
      wc2017 = 'http://www.isuresults.com/results/season1617/wc2017/'

      @updater.update_competition(wc2017, season_from: '2012-13', season_to: '2014-15')
      @updater.update_competition(wc2014, season_from: '2012-13', season_to: '2014-15', categories: ['DUMMY'])

      expect(Competition.find_by(site_url: wc2014)).not_to be nil
      expect(Competition.find_by(site_url: wc2017)).to be nil
    }
  end

=begin
## TODO: force option spec
  describe 'force' do
    it {
      url = 'http://www.isuresults.com/results/season1617/wc2017/'
      @updater.update_competition(url)

      original_competition = Competition.find_by(site_url: url)
      @updater.update_competition(url)
      new_competition = Competition.find_by(site_url: url)
      expect(original_competition).to eq(new_competition)

      ## force
      @updater.update_competition(url, force: true)
      expect(original_competition).to be nil
    }
=end
  describe 'competition_type / short_name' do
    [['http://www.isuresults.com/results/season1617/gpjpn2016/',
      :isu, :gp, 'GPJPN2016'],
     ['http://www.isuresults.com/results/season1617/gpf1617/',
      :isu, :gp, 'GPF2016'],
     ['http://www.isuresults.com/results/owg2014/',
      :isu, :olympic, 'OWG2014'],
     ['http://www.isuresults.com/results/season1617/wc2017/',
      :isu, :world, 'WORLD2017'],
     ['http://www.isuresults.com/results/season1617/fc2017/',
      :isu, :fcc, 'FCC2017'],
     ['http://www.isuresults.com/results/season1617/ec2017/',
      :isu, :euro, 'EURO2017'],
     ['http://www.isuresults.com/results/wtt2012/',
      :isu, :team, 'TEAM2012'],
     ['http://www.isuresults.com/results/season1617/wjc2017/',
      :isu, :jworld, 'JWORLD2017'],
     ['http://www.isuresults.com/results/season1617/jgpger2016/',
      :isu, :jgp, 'JGPGER2016'],
     ['http://www.figureskatingresults.fi/results/1617/CSFIN2016/',
      :challenger, :finlandia, 'FINLANDIA2016']]
      .each do |ary|
      ## TODO: competition_class, and other examples to add
      context ary[0] do
        let(:url) { ary[0] }
        let(:competition_class) { ary[1].to_s }
        let(:competition_type) { ary[2].to_s }
        let(:short_name) { ary[3] }
        let(:updater) { CompetitionUpdater.new }

        subject(:competition) { updater.update_competition(url, categories: ['DUMMY']) }
        it {
          expect(competition.site_url).to eq(url)
          expect(competition.competition_class).to eq(competition_class)
          expect(competition.competition_type).to eq(competition_type)
          expect(competition.short_name).to eq(short_name)
        }
      end
    end
  end
  ################################################################

  describe 'skater name correction' do
    def expect_same_skater(url, category, ranking) # TODO
      updater = CompetitionUpdater.new
      competition = updater.update_competition(url, categories: [category])
      cr = competition.results.find_by(category: category, ranking: ranking)
      expect(cr.skater).to eq(cr.short.skater)
      expect(cr.skater).to eq(cr.free.skater)
    end
    shared_context :skater_having_different_name do |url, category, ranking|
      subject(:result) {
        CompetitionUpdater.new.update_competition(url, categories: [category]).category_results.find_by(category: category, ranking: ranking)
      }
    end
    shared_examples :same_name_between_segments do
      its(:skater) { is_expected.to eq(result.short.skater) }
      its(:skater) { is_expected.to eq(result.free.skater) }
    end

    context 'Sandra KHOPON (fc2012)' do # Sandra KHOPON or KOHPON ??
      url = 'http://www.isuresults.com/results/fc2012/'
      include_context :skater_having_different_name, url, Category.find_by(name: 'LADIES'), 15
      it_behaves_like :same_name_between_segments
    end
=begin
    ## this site causes HTTP error
    context 'warsaw13: Mariya1 BAKUSHEVA' do   # 17 = 20, 18 / Mariya BAKUSHEVA
      url = 'http://www.pfsa.com.pl/results/1314/WC2013/'
      include_context :skater_having_different_name, url, Category.find_by(name: "JUNIOR LADIES"), 17
      it_behaves_like :same_name_between_segments
    end
=end
=begin
    it 'Ho Jung LEE / Kang In KAM' do     # Ho Jung LEE / Richard Kang In KAM
      ## TODO: name correction for Ho Jung LEE
    end
=end
  end
################
=begin
=end
  ################
  describe 'encoding' do
    it 'parses iso-8859-1' do
      url = 'http://www.isuresults.com/results/season1516/wjc2016/'
      CompetitionUpdater.new.update_competition(url, categories: ['JUNIOR LADIES'])
      expect(Competition.find_by(site_url: url).category_results.where(category: 'JUNIOR LADIES').count).to be >= 0
    end
    it 'parses unicode (fin2014)' do
      url = 'http://www.figureskatingresults.fi/results/1415/CSFIN2014/'
      CompetitionUpdater.new.update_competition(url, categories: ['MEN'])

      expect(Competition.find_by(site_url: url).scores.count).to be >= 0
    end
  end
  ################
  describe 'network errors' do
=begin
## TODO: TEMPOLARY COMMENTED OUT DUE TO SLOW NETWORK CONNECTION
    describe 'rescue not found on nepela2014/pairs and count' do
      let(:competition){
        url = 'http://www.kraso.sk/wp-content/uploads/sutaze/2014_2015/20141001_ont/html/'
        CompetitionUpdater.new(verbose: true).update_competition(url, categories: ['PAIRS'])
      }
      it { expect(competition.results.where(category: "PAIRS").count).to be_zero }
      #expect(Competition.find_by(site_url: url).results.where(category: "PAIRS").count).to be_zero
    end
=end
    describe 'rescue socket error and return value' do
      subject {
        url = 'http://xxxxxzzzzxxx.com/qqqq.pdf'
        CompetitionUpdater.new.update_competition(url, categories: ['MEN'])
      }
      it { is_expected.to be_nil }
    end

    describe 'rescue http error and return value' do
      subject {
        url = 'http://www.isuresults.com/results/season1617/wc2017/zzzzzzzzzzzzzz.pdf'
        CompetitionUpdater.new.update_competition(url)
      }
      it { is_expected.to be_nil }
    end
  end
end
