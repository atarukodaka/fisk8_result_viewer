require 'rails_helper'
#require 'fisk8viewer/updater/competition_updater'

RSpec.configure do |c|
  c.filter_run_excluding updater: true
end

RSpec.describe 'update competition', type: :competition_updater, updater: true do
  describe 'update competition: isu generic' do 
    it {
      url = 'http://www.isuresults.com/results/season1617/wc2017/'
      updater = Fisk8ResultViewer::Competition::Updater.new
      updater.update_competition(url, accept_categories: [:MEN])
                                 

      comp = Competition.find_by(site_url: url)
      expect(comp.site_url).to eq(url)
      expect(comp.scores.pluck(:category).uniq).to include('MEN')
    }
  end

  describe 'mdy format to work' do 
    it {
      url = 'http://www.isuresults.com/results/jgpfra2010/'
      updater = Fisk8ResultViewer::Competition::Updater.new
      updater.update_competition(url, accept_categories: [])

      comp = Competition.find_by(site_url: url)
      expect(comp.site_url).to eq(url)
    }
  end

  describe 'update competition: wtt2017' do 
    it {
      url = 'http://www.jsfresults.com/intl/2016-2017/wtt/'
      updater = Fisk8ResultViewer::Competition::Updater.new
      updater.update_competition(url, parser_type: :wtt_2017, accept_categories: [:MEN])
      
      comp = Competition.find_by(site_url: url)
      expect(comp.site_url).to eq(url)
    }
  end
  describe 'update competition: fc2012: correction for Sandra KHOPON' do 
    it {
      url = 'http://www.isuresults.com/results/fc2012/'
      updater = Fisk8ResultViewer::Competition::Updater.new
      updater.update_competition(url, accept_categories: [:LADIES])

      comp = Competition.find_by(site_url: url)
      expect(comp.site_url).to eq(url)
    }
  end
  ################
  describe 'load_file', type: :load_file do
    it {
      fname = File.join(Rails.root, "config/competitions.yml")
      items = Fisk8ResultViewer::Competition::Updater.new.load_competition_list(fname)
      expect(items.size).to be > 0
    }
  end
  
  describe 'competition_type / cid', type: :competition_type do
    it {
      updater = Fisk8ResultViewer::Competition::Updater.new
      # gps
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
             ]
      data.each do |ary|
        url, competition_type, cid = ary
        competition = updater.update_competition(url, accept_categories: [])
        expect(competition.site_url).to eq(url)
        expect(competition.competition_type.to_sym).to eq(competition_type)
        expect(competition.cid).to eq(cid)
      end
    }
  end
  describe 'fcc2012' do
    it {
      url = 'http://www.isuresults.com/results/fc2012/'

      updater = Fisk8ResultViewer::Competition::Updater.new
      competition = updater.update_competition(url, accept_categories: [:LADIES])
      # 15. Sandra KHOPON: 17/16
      skater_cr = competition.category_results.find_by(category: "LADIES", ranking: 15).skater
      skater_sp = competition.scores.find_by(category: "LADIES", segment: "SHORT PROGRAM", ranking: 17).skater
      skater_fs = competition.scores.find_by(category: "LADIES", segment: "FREE SKATING", ranking: 16).skater

      expect(skater_cr.id).to eq(skater_sp.id)
      expect(skater_cr.id).to eq(skater_fs.id)
    }
  end
  
  describe 'force option' do
    it {
      updater = Fisk8ResultViewer::Competition::Updater.new
      url = 'http://www.isuresults.com/results/season1617/wc2017/'
      ## update first
      comp1 = updater.update_competition(url, accept_categories: [:LADIES])
      ## update again, then should skip
      comp2 = updater.update_competition(url, accept_categories: [:LADIES])

      expect(comp1.id).to eq(comp2.id)
      ## update again with force, then should re-create
      Competition.destroy_existings_by_url(url)
      comp3 = updater.update_competition(url)
      expect(comp1.id).not_to eq(comp3.id)
      expect(comp3.site_url).to eq(url)
    }
  end
  
end
