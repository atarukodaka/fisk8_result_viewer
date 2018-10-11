require 'rails_helper'
require 'rake'

RSpec.describe 'rake', rake: true do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('update', [Rails.root.join('lib/tasks')])
    Rake.application.rake_require('parse', [Rails.root.join('lib/tasks')])
    Rake::Task.define_task(:environment)
  end

  describe 'update skater' do
    describe 'skaters' do
      it do
        ENV['quiet'] = '1'
        @rake['update:skaters'].invoke
        expect(Skater.count).to be > 0
      end
    end
    describe 'skater detail' do
      it {
        isu_number = 10_967
        ENV['isu_number'] = isu_number.to_s
        ENV['quiet'] = '1'
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
      ENV['quiet'] = '1'
      @rake['update:competitions'].execute
      site_url = CompetitionList.last.site_url
      expect(Competition.find_by(site_url: site_url).site_url).to eq(site_url)
    }
  end
  ################
  describe 'deviation' do
    it {
      ENV['last'] = '1'
      ENV['enable_judge_details'] = '1'
      ENV['quiet'] = '1'
      expect(@rake['update:competitions'].invoke).to be_truthy
      expect(@rake['update:deviations'].invoke).to be_truthy
    }
  end
  ################
  describe 'parse scores' do
    it do
      ENV['url'] = 'http://www.isuresults.com/results/season1617/wc2017/wc2017_Men_SP_Scores.pdf'
      ENV['quiet'] = '1'
      expect(@rake['parse:scores'].invoke).to be_truthy
    end
  end
end
