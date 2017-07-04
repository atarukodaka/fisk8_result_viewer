require 'rails_helper'

RSpec.configure do |c|
  c.filter_run_excluding updater: true
end

RSpec.describe 'update competition', type: :competition_updater, updater: true do
  context 'update' do
    it 'updates wc2017' do
      url = 'http://www.isuresults.com/results/season1617/wc2017/'
      Competition.create_competition(url)
      comp = Competition.find_by(site_url: url)
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
        competition = Competition.create_competition(url, accept_categories: [])
        expect(competition.site_url).to eq(url)
        expect(competition.competition_type.to_sym).to eq(competition_type)
        expect(competition.short_name).to eq(short_name)
      end
    }
  end

  context 'parser types:' do
    it 'works on mdy date format' do
      url = 'http://www.isuresults.com/results/jgpfra2010/'
      Competition.create_competition(url)

      comp = Competition.find_by(site_url: url)
      expect(comp.site_url).to eq(url)
    end

    it 'parses wtt2017' do
      url = 'http://www.jsfresults.com/intl/2016-2017/wtt/'
      Competition.create_competition(url, parser_type: :wtt_2017)
      
      comp = Competition.find_by(site_url: url)
      expect(comp.site_url).to eq(url)
    end
    it 'parses autumn classic' do
      url = 'https://skatecanada.ca/event/2016-autumn-classic-international/'
      Competition.create_competition(url, parser_type: :autumn_classic)
      
      comp = Competition.find_by(site_url: url)
      expect(comp.site_url).to eq(url)
    end
  end

  context 'skater name correction' do
    it 'corrects skater name (fc2012)' do
      url = 'http://www.isuresults.com/results/fc2012/'

      competition = Competition.create_competition(url, accept_categories: [:LADIES])
      # 15. Sandra KHOPON: 17/16
      skater_cr = competition.category_results.find_by(category: "LADIES", ranking: 15).skater
      skater_sp = competition.scores.find_by(category: "LADIES", segment: "SHORT PROGRAM", ranking: 17).skater
      skater_fs = competition.scores.find_by(category: "LADIES", segment: "FREE SKATING", ranking: 16).skater

      expect(skater_cr.id).to eq(skater_sp.id)
      expect(skater_cr.id).to eq(skater_fs.id)
    end
  end
  context 'encoding' do
    it 'parses iso-8859-1' do
      url = 'http://www.isuresults.com/results/season1516/wjc2016/'
      Competition.create_competition(url, accept_categories: [:"JUNIOR LADIES"])
      expect(Competition.find_by(site_url: url).category_results.where(category: "JUNIOR LADIES").count).to be >= 0
    end
    it 'parses unicode (fin2014)' do
      url = 'http://www.figureskatingresults.fi/results/1415/CSFIN2014/'
      Competition.create_competition(url, accept_categories: [:MEN])
      
      expect(Competition.find_by(site_url: url).scores.count).to be >= 0
    end
  end
  context 'network errors' do
    it 'raises socket error' do
        url = 'http://xxxxxzzzzxxx.com/qqqq.pdf'
      expect {
        Competition.create_competition(url, accept_categories: [:MEN])
      }.to raise_error SocketError
    end
    
    it 'raises http error' do
      url = 'http://www.isuresults.com/results/season1617/wc2017/zzzzzzzzzzzzzz.pdf'
      expect { Competition.create_competition(url, accept_categories: [:MEN]) }.to raise_error OpenURI::HTTPError
    end
  end
end
