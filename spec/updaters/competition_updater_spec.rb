require 'rails_helper'

RSpec.configure do |c|
  c.filter_run_excluding updater: true
end

RSpec.describe 'update competition', type: :competition_updater, updater: true do
  before do
    @men_updater = Fisk8ResultViewer::Updater::CompetitionUpdater.new(accept_categories: [:MEN], quiet: true)
    @non_updater = Fisk8ResultViewer::Updater::CompetitionUpdater.new(accept_categories: [], quiet: true)
  end
  it 'works with isu-generic' do
    url = 'http://www.isuresults.com/results/season1617/wc2017/'
    @men_updater.update_competition(url)
    
    comp = Competition.find_by(site_url: url)
    expect(comp.site_url).to eq(url)
    expect(comp.scores.pluck(:category).uniq).to include('MEN')
  end

  describe 'competition_type / short_name', type: :competition_type do
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
        competition = @non_updater.update_competition(url)
        expect(competition.site_url).to eq(url)
        expect(competition.competition_type.to_sym).to eq(competition_type)
        expect(competition.short_name).to eq(short_name)
      end
    }
  end

  describe 'load_file', type: :load_file do
    it {
      items = Fisk8ResultViewer::Updater::CompetitionUpdater.new.load_competition_list
      expect(items.size).to be > 0
    }
  end

  context 'parser types:' do
    it 'works on mdy date format' do
      url = 'http://www.isuresults.com/results/jgpfra2010/'
      @non_updater.update_competition(url)

      comp = Competition.find_by(site_url: url)
      expect(comp.site_url).to eq(url)
    end

    it 'parses wtt2017' do
      url = 'http://www.jsfresults.com/intl/2016-2017/wtt/'
      @men_updater.update_competition(url, parser_type: :wtt_2017)
      
      comp = Competition.find_by(site_url: url)
      expect(comp.site_url).to eq(url)
    end
    it 'parses autumn classic' do
      url = 'https://skatecanada.ca/event/2016-autumn-classic-international/'
      @men_updater.update_competition(url, parser_type: :autumn_classic)
      
      comp = Competition.find_by(site_url: url)
      expect(comp.site_url).to eq(url)
    end
  end

  context 'skater name correction' do
    it 'corrects skater name (fc2012)' do
      url = 'http://www.isuresults.com/results/fc2012/'

      updater = Fisk8ResultViewer::Updater::CompetitionUpdater.new(accept_categories: [:LADIES])
      competition = updater.update_competition(url)
      # 15. Sandra KHOPON: 17/16
      skater_cr = competition.category_results.find_by(category: "LADIES", ranking: 15).skater
      skater_sp = competition.scores.find_by(category: "LADIES", segment: "SHORT PROGRAM", ranking: 17).skater
      skater_fs = competition.scores.find_by(category: "LADIES", segment: "FREE SKATING", ranking: 16).skater

      expect(skater_cr.id).to eq(skater_sp.id)
      expect(skater_cr.id).to eq(skater_fs.id)
    end
  end
  context 'options' do
    it 'recognises force' do
      url = 'http://www.isuresults.com/results/season1617/wc2017/'
      ## update first
      comp1 = @men_updater.update_competition(url)      ## update again, then should skip
      comp2 = @men_updater.update_competition(url)

      expect(comp1.id).to eq(comp2.id)
      ## update again with force, then should re-create
      Competition.destroy_existings_by_url(url)
      comp3 = @men_updater.update_competition(url)
      expect(comp1.id).not_to eq(comp3.id)
      expect(comp3.site_url).to eq(url)
    end
  end
  context 'encoding' do
    it 'parses iso-8859-1' do
      url = 'http://www.isuresults.com/results/season1516/wjc2016/'
      updater = Fisk8ResultViewer::Updater::CompetitionUpdater.new(accept_categories: [:"JUNIOR LADIES"])
      updater.update_competition(url)
      expect(Competition.find_by(site_url: url).category_results.where(category: "JUNIOR LADIES").count).to be >= 0
    end
    it 'parses unicode (fin2014)' do
      url = 'http://www.figureskatingresults.fi/results/1415/CSFIN2014/'
      @men_updater.update_competition(url)
      expect(Competition.find_by(site_url: url).scores.count).to be >= 0
    end
  end
  context 'http error' do
    it do
      url = 'http://xxxxxzzzzxxx.com/qqqq.pdf'
      #expect {updater.update_competition(url) }.to raise_error OpenURI::HTTPError || SocketError
      expect {@men_updater.update_competition(url) }.to raise_error SocketError
    end
  end
end
