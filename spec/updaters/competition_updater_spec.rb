require 'rails_helper'
using StringToModel

RSpec.describe Competition, type: :competition_updater, updater: true do
  let(:updater) { CompetitionUpdater.new }

  shared_examples :having_competition_with_url do
    its(:site_url) { is_expected.to eq(url) }
  end

  shared_examples :having_score_with_category_of do |category_name|
    it { expect(competition.scores.first.category.name).to eq(category_name) }
  end

  describe 'parser types:' do
    ################
    describe 'wc2017 with isu_generic' do
      let(:url) { 'http://www.isuresults.com/results/season1617/wc2017/' }
      subject { updater.update_competition(url) }
      it_behaves_like :having_competition_with_url
    end
    describe 'date_format: jgpfra2010 with isu_generic for mdy_date type' do
      let(:url) { 'http://www.isuresults.com/results/jgpfra2010/' }
      let(:date_format) { '%m/%d/%Y' }
      subject { updater.update_competition(url, categories: ['MEN'], date_format: date_format) }
      it_behaves_like :having_competition_with_url
    end

    describe 'wtt2017' do
      let(:url) { 'https://www.jsfresults.com/intl/2016-2017/wtt/' }
      subject {
        updater.update_competition(url, categories: [], parser_type: :wtt2017)
      }
      it_behaves_like :having_competition_with_url
    end

    describe 'gpjpn' do
      let(:url) { 'http://www.isuresults.com/results/season1718/gpf1718/' }
      subject {
        updater.update_competition(url, categories: ['MEN'], parser_type: :gpjpn)
      }
      it_behaves_like :having_competition_with_url
    end
  end

  describe 'team' do
    describe 'wtt2017' do
      let(:url) { 'https://www.jsfresults.com/intl/2016-2017/wtt/' }
      subject(:competition) {
        updater.update_competition(url, categories: ['TEAM MEN'], parser_type: :wtt2017)
      }
      it_behaves_like :having_score_with_category_of, 'TEAM MEN'
    end
    describe 'owgteam' do
      let(:url) { 'http://www.isuresults.com/results/season1718/owg2018/' }
      subject(:competition) { updater.update_competition(url, categories: ['TEAM MEN']) }
      it_behaves_like :having_score_with_category_of, 'TEAM MEN'
    end
  end

  describe 'special' do
    describe 'gpfra2015 - no free skating' do
      let(:url) { 'http://www.isuresults.com/results/season1516/gpfra2015/' }
      subject(:competition) { updater.update_competition(url, categories: ['MEN']) }
      it_behaves_like :having_competition_with_url
    end
    describe 'csfin' do
      let(:url) { 'http://www.figureskatingresults.fi/results/1617/CSFIN2016/' }
      subject {
        updater.update_competition(url, categories: ['MEN'])
      }
      it_behaves_like :having_competition_with_url
    end
  end
  describe 'live results' do
    describe 'gpfra2016/ICE DANCE' do
      let(:url) { 'http://www.isuresults.com/results/season1617/gpfra2016' }
      subject(:competition) { updater.update_competition(url, categories: ['ICE DANCE']) }
      # it {    expect(competition.scores.first.category.name).to eq('ICE DANCE')        }
      it_behaves_like :having_score_with_category_of, 'ICE DANCE'
    end
    describe 'gpchn2017/LADIES' do
      let(:url) { 'http://www.isuresults.com/results/season1718/gpchn2017/' }
      subject(:competition) { updater.update_competition(url, categories: ['LADIES']) }
      # it {    expect(competition.scores.first.category.name).to eq('LADIES')        }
      it_behaves_like :having_score_with_category_of, 'LADIES'
    end
  end

  describe 'enable_judge_details' do
    it {
      url = 'http://www.isuresults.com/results/season1617/wc2017/'
      updater = CompetitionUpdater.new(verbose: false)

      updater.update_competition(url, categories: ['MEN'], enable_judge_details: true)
      expect(ElementJudgeDetail.count).to be > 0
      expect(ComponentJudgeDetail.count).to be > 0
    }
  end

  describe 'season from/to' do
    it {
      wc2014 = 'http://www.isuresults.com/results/wc2014/'
      wc2017 = 'http://www.isuresults.com/results/season1617/wc2017/'

      updater.update_competition(wc2017, season_from: '2012-13', season_to: '2014-15',
                                  categories: [])
      updater.update_competition(wc2014, season_from: '2012-13', season_to: '2014-15',
                                  categories: [])

      expect(Competition.find_by(site_url: wc2014)).not_to be nil
      expect(Competition.find_by(site_url: wc2017)).to be nil
    }
  end

  describe 'force' do
    let(:url) { 'http://www.isuresults.com/results/season1617/wc2017/' }
    let(:original) { updater.update_competition(url, categories: ['MEN']).reload }

    describe 'non_forced' do
      subject(:non_forced) { updater.update_competition(url, categories: ['MEN']).reload }
      its(:updated_at) { is_expected.to eq(original.updated_at) }
    end

    describe 'forced' do
      subject(:forced) { updater.update_competition(url, force: true, categories: ['MEN']).reload }
      its(:updated_at) { is_expected.to eq(original.updated_at) }
    end
  end

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
      :challenger, :finlandia, 'FINLANDIA2016'],
     ['http://www.isuresults.com/results/season1718/csger2017/',
      :challenger, :nebelhorn, 'NEBELHORN2017'],
     ['http://www.fisg.it/upload/result/4468/index.html',
      :challenger, :lombardia, 'LOMBARDIA2017'],
     ['http://www.kraso.sk/wp-content/uploads/sutaze/2017_2018/20170921_ont/',
      :challenger, :nepela, 'NEPELA2017'],
     ['http://www.pfsa.com.pl/results/1314/WC2013/',
      :challenger, :warsaw, 'WARSAW2013'],].each do |ary|
      ## TODO: competition_class, and other examples to add
      context ary[0] do
        let(:url) { ary[0] }
        let(:competition_class) { ary[1].to_s }
        let(:competition_type) { ary[2].to_s }
        let(:short_name) { ary[3] }

        subject(:competition) { updater.update_competition(url, categories: []) }
        it {
          expect(competition.site_url).to eq(url)
          expect(competition.competition_class).to eq(competition_class)
          expect(competition.competition_type).to eq(competition_type)
          expect(competition.short_name).to eq(short_name)
        }
      end
    end
  end

  ################
  describe 'skater name correction' do
    def expect_same_skater(url, category, ranking) # TODO
      competition = updater.update_competition(url, categories: [category])
      cr = competition.results.find_by(category: category, ranking: ranking)
      expect(cr.skater).to eq(cr.short.skater)
      expect(cr.skater).to eq(cr.free.skater)
    end
    shared_context :skater_having_different_name do |url, category, ranking|
      subject(:result) {
        CompetitionUpdater.new.update_competition(url, categories: [category])
          .category_results.where("categories.name": category, ranking: ranking).joins(:category).first
      }
    end
    shared_examples :same_name_between_segments do
      its(:skater) { is_expected.to eq(result.short.skater) }
      its(:skater) { is_expected.to eq(result.free.skater) }
    end

    context 'Sandra KHOPON (fc2012)' do # Sandra KHOPON or KOHPON ??
      url = 'http://www.isuresults.com/results/fc2012/'
      include_context :skater_having_different_name, url, 'LADIES', 15
      it_behaves_like :same_name_between_segments
    end
=begin
    ## TODO: TEMPOLARY COMMENTED OUT DUE TO SLOW NETWORK CONNECTION
    context 'warsaw13: Mariya1 BAKUSHEVA' do   # 17 = 20, 18 / Mariya BAKUSHEVA
      url = 'http://www.pfsa.com.pl/results/1314/WC2013/'
      include_context :skater_having_different_name, url, 'JUNIOR LADIES', 17
      it_behaves_like :same_name_between_segments
    end
=end
  end
  ################
  describe 'encoding' do
    it 'parses iso-8859-1' do
      url = 'http://www.isuresults.com/results/season1516/wjc2016/'
      CompetitionUpdater.new.update_competition(url, categories: ['JUNIOR LADIES'])
      results = Competition.find_by(site_url: url).category_results.where(category: 'JUNIOR LADIES')
      expect(results.count).to be >= 0
    end
=begin
## TODO: TEMPOLARY COMMENTED OUT DUE TO SLOW NETWORK CONNECTION
    it 'parses unicode (fin2014)' do
      url = 'http://www.figureskatingresults.fi/results/1415/CSFIN2014/'
      CompetitionUpdater.new.update_competition(url, categories: ['MEN'])

      expect(Competition.find_by(site_url: url).scores.count).to be >= 0
    end
=end
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
