require 'rails_helper'
require 'rake'

RSpec.configure do |c|
  c.filter_run_excluding rake: true
end

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
    def expect_url_match(last: 2, categories: '')
      ENV['last'] = last.to_s
      ENV['categories'] = categories
      @rake['update:competitions'].execute

      CompetitionList.all.last(last).each do |item|
        expect(Competition.find_by(site_url: item[:site_url])).not_to be_nil
      end
    end
    it 'by competitions.yml' do
      expect_url_match
    end
    it 'by filename' do
      ENV['filename'] = 'competitions_junior'
      expect_url_match
    end
    it 'by filenames' do
      ENV['filenames'] = 'competitions_junior,competitions_challenger'
      expect_url_match
    end
    it 'categories' do
      expect_url_match(categories: 'MEN', last: 1)
      expect(Score.joins(:category).where("categories.name": 'MEN').count).to be > 0
    end
    it 'by force' do ## TODo
      ENV['force'] = '1'
      # expect_url_match
    end
  end
  ################
  describe 'deviation' do
    it {
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
