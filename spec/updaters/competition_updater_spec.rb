require 'rails_helper'

RSpec.configure do |c|
  c.filter_run_excluding updater: true
end

RSpec.describe 'update competition', type: :competition_updater, updater: true do
  context 'update' do
    it 'updates wc2017' do
      url = 'http://www.isuresults.com/results/season1617/wc2017/'
      comp = Competition.create(site_url: url).update!
      expect(comp.site_url).to eq(url)
      expect(comp.scores.pluck(:category).uniq).to include('MEN')      
    end
  end

  context 'competition_type / short_name' do
    it {
      data = [['http://www.isuresults.com/results/season1617/gpjpn2016/',
               :gp, 'GPJPN2016'],
              ['http://www.isuresults.com/results/season1617/gpf1617/',
               :gp, 'GPF2016'],
              ['http://www.isuresults.com/results/owg2014/',
               :olympic, 'OLYMPIC2014'],
              ['http://www.isuresults.com/results/season1617/wc2017/',
               :world, 'WORLD2017'],
              ['http://www.isuresults.com/results/season1617/fc2017/',
              :fcc, 'FCC2017'],
              ['http://www.isuresults.com/results/season1617/ec2017/',
              :euro, 'EURO2017'],
              ['http://www.isuresults.com/results/wtt2012/',
               :team, 'TEAM2012'],
              ['http://www.isuresults.com/results/season1617/wjc2017/',
               :jworld, 'JWORLD2017'],
              ['http://www.isuresults.com/results/season1617/jgpger2016/',
               :jgp, 'JGPGER2016'],
              #['',
              #:challenger, 'FINLANDIA2016'],
             ]
      data.each do |ary|
        url, competition_type, short_name = ary
        Category.accept!([])
        competition = Competition.create(site_url: url).update!
        expect(competition.site_url).to eq(url)
        expect(competition.competition_type.to_sym).to eq(competition_type)
        expect(competition.short_name).to eq(short_name)
      end
    }
  end

  context 'parser types:' do
    it 'works on mdy date format' do
      url = 'http://www.isuresults.com/results/jgpfra2010/'
      Competition.create(site_url: url).update!

      comp = Competition.find_by(site_url: url)
      expect(comp.site_url).to eq(url)
    end

    it 'parses wtt2017' do
      url = 'http://www.jsfresults.com/intl/2016-2017/wtt/'
      Competition.create(site_url: url, parser_type: :wtt_2017).update!
      
      comp = Competition.find_by(site_url: url)
      expect(comp.site_url).to eq(url)
    end
    it 'parses autumn classic' do
      url = 'https://skatecanada.ca/event/2016-autumn-classic-international/'
      Competition.create(site_url: url, parser_type: :autumn_classic).update!
      
      comp = Competition.find_by(site_url: url)
      expect(comp.site_url).to eq(url)
    end
  end

  context 'skater name correction' do
    def expect_same_skater(url, category, ranking)
      Category.accept!(category)
      competition = Competition.create(site_url: url).update!
      cr = competition.category_results.find_by(category: category, ranking: ranking)
      expect(cr.skater).to eq(cr.short.skater)
      expect(cr.skater).to eq(cr.free.skater)      
    end
    it 'Sandra KOHPON (fc2012)' do  # Sandra KHOPON
      url = 'http://www.isuresults.com/results/fc2012/'

      expect_same_skater(url, :LADIES, 15)
    end
    it 'warsaw13: Mariya1 BAKUSHEVA' do   # 17 = 20, 18 / Mariya BAKUSHEVA
      url = 'http://www.pfsa.com.pl/results/1314/WC2013/'
      expect_same_skater(url, :"JUNIOR LADIES", 17)
    end
    it 'Ho Jung LEE / Kang In KAM' do     # Ho Jung LEE / Richard Kang In KAM
      ## TODO: name correction for Ho Jung LEE
    end
  end
  context 'encoding' do
    it 'parses iso-8859-1' do
      url = 'http://www.isuresults.com/results/season1516/wjc2016/'
      Category.accept!("JUNIOR LADIES")
      Competition.create(site_url: url).update!
      expect(Competition.find_by(site_url: url).category_results.where(category: "JUNIOR LADIES").count).to be >= 0
    end
    it 'parses unicode (fin2014)' do
      url = 'http://www.figureskatingresults.fi/results/1415/CSFIN2014/'
      Category.accept!("MEN")
      Competition.create(site_url: url).update!
      
      expect(Competition.find_by(site_url: url).scores.count).to be >= 0
    end
  end
  context 'network errors' do
    it 'rescue not found on nepera2014/pairs' do
      url = 'http://www.kraso.sk/wp-content/uploads/sutaze/2014_2015/20141001_ont/html/'
      Category.accept!("PAIRS")
      Competition.create(site_url: url).update!
      expect(Competition.find_by(site_url: url).category_results.where(category: "PAIRS").count).to be_zero
    end
    it 'raises socket error' do
        url = 'http://xxxxxzzzzxxx.com/qqqq.pdf'
      expect {
        Category.accept!("MEN")
        Competition.create(site_url: url).update!
      }.to raise_error SocketError
    end
    
    it 'raises http error' do
      url = 'http://www.isuresults.com/results/season1617/wc2017/zzzzzzzzzzzzzz.pdf'
      Category.accept!("MEN")
      expect { Competition.create(site_url: url).update! }.to raise_error OpenURI::HTTPError
    end
  end
end
