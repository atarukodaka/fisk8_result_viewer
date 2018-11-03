require 'rails_helper'
require 'rake'

RSpec.describe 'rake', rake: true, vcr: true do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('update', [Rails.root.join('lib', 'tasks')])
    Rake.application.rake_require('parse', [Rails.root.join('lib', 'tasks')])
    Rake::Task.define_task(:environment)
  end

  describe 'update skater' do
    describe 'skaters' do
      it do
        @rake['update:skaters'].invoke
        expect(Skater.count).to be > 0
      end
    end
    describe 'skater detail' do
      it {
        isu_number = 10_967
        ENV['isu_number'] = isu_number.to_s
        @rake['update:skater_detail'].invoke
        expect(Skater.find_by(isu_number: isu_number).coach).not_to be_nil
      }
    end
  end

  ################
  context 'update competition' do
    it {
      site_url = 'http://www.isuresults.com/results/season1718/wc2018/'
      ENV['site_url'] = site_url
      @rake['update:competition'].execute
      expect(Competition.find_by(site_url: site_url).site_url).to eq(site_url)
    }
  end
  context 'update competitions' do
    it {
      ENV['last'] = '1'
      @rake['update:competitions'].execute
      site_url = CompetitionList.last.site_url
      expect(Competition.find_by(site_url: site_url).site_url).to eq(site_url)
    }
  end
  ################
  describe 'update grandprix' do
    it {
      ## TODO: ladies, pairs as well
      url = 'http://www.isuresults.com/events/gp2018/gpsmen.htm'
      WebMock.enable!
      WebMock.stub_request(:get, url).to_return(
        body: File.read((Rails.root.join('spec/fixtures/webmock', 'gp2018-men.htm')).to_s),
        status: 200
      )

      ENV['season'] = '2018-19'
      @rake['update:grandprix'].execute
      expect(GrandprixEvent.count).to eq(18)
    }
  end
  ################
  describe 'parse scores' do
    it {
      ENV['url'] = 'http://www.isuresults.com/results/season1617/wc2017/wc2017_Men_SP_Scores.pdf'
      expect(@rake['parse:scores'].invoke).to be_truthy
    }
  end
end
