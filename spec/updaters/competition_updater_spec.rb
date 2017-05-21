require 'rails_helper'
require 'fisk8viewer'

RSpec.configure do |c|
  c.filter_run_excluding updater: true
end

RSpec.describe 'update competition', type: :competition_updater, updater: true do
  describe 'update competition: isu generic' do 
    it {
      url = 'http://www.isuresults.com/results/season1617/wc2017/'
      updater = Fisk8Viewer::Updater::CompetitionUpdater.new(accept_categories: [])
      updater.update_competition(url)

      comp = Competition.find_by(site_url: url)
      expect(comp.site_url).to eq(url)
    }
  end

  describe 'update competition: isu generic mdy' do 
    it {
      url = 'http://www.isuresults.com/results/jgpfra2010/'
      updater = Fisk8Viewer::Updater::CompetitionUpdater.new(accept_categories: [])
      updater.update_competition(url, parser_type: :isu_generic_mdy)

      comp = Competition.find_by(site_url: url)
      expect(comp.site_url).to eq(url)
    }
  end

  describe 'update competition: wtt2017' do 
    it {
      url = 'http://www.jsfresults.com/intl/2016-2017/wtt/'
      updater = Fisk8Viewer::Updater::CompetitionUpdater.new(accept_categories: [])
      updater.update_competition(url, parser_type: :wtt_2017)

      comp = Competition.find_by(site_url: url)
      expect(comp.site_url).to eq(url)
    }
  end
end
