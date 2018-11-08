require 'rails_helper'
using StringToModel

RSpec.describe CompetitionUpdater, updater: true, vcr: true do
  let(:updater) { CompetitionUpdater.new }

  shared_examples :having_competition_with_url do
    its(:site_url) { is_expected.to eq(url) }
  end

  def having_scores_with_category_of(category_name)
    expect(subject.scores.where(category: category_name.to_category)).not_to be_empty
  end
  shared_examples :having_scores_with_category_of do |category_name|
    it { having_scores_with_category_of(category_name) }
  end

  describe 'wc2017' do
    let(:site_url) { 'http://www.isuresults.com/results/season1617/wc2017/' }
    subject { updater.update_competition(site_url) }
    it {
      expect(subject.site_url).to eq(site_url)
      expect(subject.category_results.count).to be > 0
      expect(subject.scores.count).to be > 0
      ['MEN', 'LADIES', 'PAIRS', 'ICE DANCE'].each do |category|
        having_scores_with_category_of(category)
      end
    }
  end

  describe 'parser types:' do
    ################
    describe 'date_format: jgpfra2010 with isu_generic for mdy_date type' do
      let(:url) { 'http://www.isuresults.com/results/jgpfra2010/' }
      let(:date_format) { '%m/%d/%Y' }
      subject { updater.update_competition(url, categories: ['MEN'], date_format: date_format) }
      its(:site_url) { is_expected.to eq(url) }
    end

    describe 'wtt2017' do
      let(:url) { 'https://www.jsfresults.com/intl/2016-2017/wtt/' }
      subject { updater.update_competition(url, categories: [], parser_type: :wtt2017) }
      its(:site_url) { is_expected.to eq(url) }
    end

    describe 'gpjpn' do
      let(:url) { 'http://www.isuresults.com/results/season1718/gpf1718/' }
      subject { updater.update_competition(url, categories: ['MEN'], parser_type: :gpjpn) }
      its(:site_url) { is_expected.to eq(url) }
    end
  end

  describe 'team' do
    describe 'wtt2017' do
      let(:url) { 'https://www.jsfresults.com/intl/2016-2017/wtt/' }
      subject { updater.update_competition(url, categories: ['TEAM MEN'], parser_type: :wtt2017)  }
      it {
        expect(subject.site_url).to eq(url)
        having_scores_with_category_of('TEAM MEN')
      }
    end
    describe 'owgteam' do
      let(:url) { 'http://www.isuresults.com/results/season1718/owg2018/' }
      subject { updater.update_competition(url, categories: ['TEAM MEN']) }
      its(:site_url) { is_expected.to eq(url) }
      it {
        expect(subject.site_url).to eq(url)
        having_scores_with_category_of('TEAM MEN')
      }
    end
  end

  describe 'special' do
    describe 'gpfra2015 - no free skating' do
      let(:url) { 'http://www.isuresults.com/results/season1516/gpfra2015/' }
      subject { updater.update_competition(url, categories: ['MEN']) }
      its(:site_url) { is_expected.to eq(url) }
    end
    describe 'csfin' do
      let(:url) { 'http://www.figureskatingresults.fi/results/1617/CSFIN2016/' }
      subject { updater.update_competition(url, categories: ['MEN'])  }
      its(:site_url) { is_expected.to eq(url) }
    end

    describe 'official absence: gpusa2016/pairs/short' do
      let(:url) { 'http://www.isuresults.com/results/season1617/gpusa2016/' }
      let(:competition) { updater.update_competition(url, categories: ['PAIRS'])  }
      let(:officials) {
        competition.performed_segments.find_by(segment: 'SHORT PROGRAM'.to_segment).officials
      }
      subject { officials.find_by(number: 6) }
      it { is_expected.to be nil }
    end
  end

  describe 'skater creation' do
    let(:url) { 'http://www.isuresults.com/results/season1617/wc2017/' }
    let(:competition) { updater.update_competition(url, categories: ['MEN']) }
    let(:score) {
      competition.scores.where(category: 'MEN'.to_category,
                               segment: 'SHORT PROGRAM'.to_segment, ranking: 1).first
    }
    let(:skater) { score.skater }
    it {
      expect(skater.name).to eq('Javier FERNANDEZ')
      expect(skater.nation).to eq('ESP')
      expect(skater.isu_number).to eq(7684)
    }
  end
=begin
  describe 'skater name correction' do
    it {
      skater_name = "Shoma UNO"
      owg_name = "UNO Shoma"

    }
  end
=end
  describe 'enable_judge_details' do
    let(:url) { 'http://www.isuresults.com/results/season1617/wc2017/' }
    let(:competition) { updater.update_competition(url, categories: ['MEN'], enable_judge_details: true) }
    let(:score) { competition.scores.first }
    let(:element) { score.elements.first }
    let(:component) { score.components.first }
    it {
      expect(element.judge_details.count).to be > 0
      expect(component.judge_details.count).to be > 0
    }
  end

  describe 'season from/to' do
    let(:url) { 'http://www.isuresults.com/results/season1617/wc2017/' }

    shared_context :season_within_range_of do |from, to, flag|
      subject { updater.update_competition(url, season_from: from, season_to: to, categories: []) }
      it {
        expected = (flag) ? be_truthy : be_nil
        is_expected.to expected
      }
    end

    describe 'past/past: out of range' do
      include_context :season_within_range_of, '2012-13', '2014-15', false
    end
    describe 'past/equal: within range' do
      include_context :season_within_range_of, '2012-13', '2016-17', true
    end
    describe 'past/feature: within range' do
      include_context :season_within_range_of, '2012-13', '2020-21', true
    end
    describe 'equal/feature: within range' do
      include_context :season_within_range_of, '2016-17', '2020-21', true
    end
    describe 'feature/feature: out of range' do
      include_context :season_within_range_of, '2017-18', '2020-21', false
    end

    describe 'nil/past: out of range' do
      include_context :season_within_range_of, nil, '2014-15', false
    end
    describe 'nil/equal: within range' do
      include_context :season_within_range_of, nil, '2016-17', true
    end
    describe 'nil/feature: within range' do
      include_context :season_within_range_of, nil, '2016-17', true
    end

    describe 'past/nil: within range' do
      include_context :season_within_range_of, '2014-15', nil, true
    end
    describe 'equal/nil: within range' do
      include_context :season_within_range_of, '2016-17', nil, true
    end
    describe 'feature/nil: out of range' do
      include_context :season_within_range_of, '2020-21', nil, false
    end
  end

  describe 'force' do
    let(:url) { 'http://www.isuresults.com/results/season1617/wc2017/' }
    let!(:original) { updater.update_competition(url, categories: ['MEN']).reload }

    describe 'non_forced' do
      subject { updater.update_competition(url, categories: ['MEN']) }
      # its(:updated_at) { is_expected.to eq(original.updated_at) }
      it { is_expected.to be_nil }
    end

    describe 'forced' do
      subject(:forced) { updater.update_competition(url, force: true, categories: ['MEN']).reload }
      its(:updated_at) { is_expected.not_to eq(original.updated_at) }
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
    shared_context :skater_having_different_name do |url, category, ranking, date_format: nil|
      subject(:result) {
        CompetitionUpdater.new.update_competition(url, categories: [category], date_format: date_format)
          .category_results.where("categories.name": category, ranking: ranking).joins(:category).first
      }
    end
    shared_examples :same_name_between_segments do
      its(:skater) { is_expected.to eq(result.short.skater) }
      its(:skater) { is_expected.to eq(result.free.skater) }
    end

    context 'Sandra KHOPON (fc2012)' do # Sandra KHOPON or KOHPON ??
      url = 'http://www.isuresults.com/results/fc2012/'
      include_context :skater_having_different_name, url, 'LADIES', 15, date_format: '%m/%d/%Y'
      it_behaves_like :same_name_between_segments
    end

    ## TODO: TEMPOLARY COMMENTED OUT DUE TO SLOW NETWORK CONNECTION
    context 'warsaw13: Mariya1 BAKUSHEVA' do   # 17 = 20, 18 / Mariya BAKUSHEVA
      url = 'http://www.pfsa.com.pl/results/1314/WC2013/'
      include_context :skater_having_different_name, url, 'JUNIOR LADIES', 17
      it_behaves_like :same_name_between_segments
    end
  end
  ################
  describe 'encoding' do
    describe 'parses iso-8859-1' do
      let(:url) { 'http://www.isuresults.com/results/season1516/wjc2016/' }
      let(:competition) { updater.update_competition(url, categories: ['JUNIOR LADIES']) }
      subject { competition.category_results.where(category: 'JUNIOR LADIES') }
      its(:count) { is_expected.to be >= 0 }
    end

    ## TODO: TEMPOLARY COMMENTED OUT DUE TO SLOW NETWORK CONNECTION
    describe 'parses unicode (fin2014)' do
      let(:url) { 'http://www.figureskatingresults.fi/results/1415/CSFIN2014/' }
      subject { updater.update_competition(url, categories: ['MEN']) }
      its(:site_url) { is_expected.to eq(url) }
    end
  end
  ################
  describe 'network errors' do
    ## TODO: TEMPOLARY COMMENTED OUT DUE TO SLOW NETWORK CONNECTION
    describe 'rescue not found on nepela2014/pairs and count' do
      let(:url) { 'http://www.kraso.sk/wp-content/uploads/sutaze/2014_2015/20141001_ont/html/' }
      let(:competition) { updater.update_competition(url, categories: ['PAIRS'], date_format: '%m/%d/%Y') }
      it { expect(competition.category_results.where(category: 'PAIRS'.to_category).count).to be_zero }
      # expect(Competition.find_by(site_url: url).results.where(category: "PAIRS").count).to be_zero
    end

    describe 'rescue socket error and return value' do
      let(:url) { 'http://xxxxxzzzzxxx.com/qqqq.pdf' }
      subject { updater.update_competition(url, categories: ['MEN']) }
      it { is_expected.to be_nil }
    end

    describe 'rescue http error and return value' do
      let(:url) { 'http://www.isuresults.com/results/season1617/wc2017/zzzzzzzzzzzzzz.pdf' }
      subject { updater.update_competition(url) }
      it { is_expected.to be_nil }
    end
  end
end
