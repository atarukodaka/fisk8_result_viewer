require 'rails_helper'
require 'rake'

RSpec.configure do |c|
  c.filter_run_excluding rake: true
end


RSpec.describe 'rake', rake: true do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('update', ["#{Rails.root}/lib/tasks"])
    Rake.application.rake_require('parse', ["#{Rails.root}/lib/tasks"])
    Rake::Task.define_task(:environment)
  end
  before(:each) do
    #@rake[task].reenable
  end
  
  it 'updates skaters' do
    ENV['accept_categories'] = 'LADIES'
    @rake['update:skaters'].invoke

    expect(Skater.count).to be > 0
  end

  context 'update competition' do
    def expect_url_match(num=nil)
      num ||= 2
      ENV['last'] = num.to_s
      ENV['accept_categories'] = ''
      @rake['update:competitions'].execute

      CompetitionList.all.last(num).each do |item|
        expect( Competition.find_by(site_url: item[:url]) ).not_to be_nil
      end
    end
    it 'by competitions.yml' do
      expect_url_match
    end
    it 'by filename' do
      ENV['filename'] ="competitions_junior"
      expect_url_match
    end
    it 'by filenames' do
      ENV['filenames'] = "competitions_junior,competitions_challenger"
      expect_url_match
    end
    it 'by force' do   ## TODo
      ENV['force'] = '1'
      #expect_url_match
    end
    
  end
  it 'parses scores' do
    ENV['url'] = 'http://www.isuresults.com/results/season1617/wc2017/wc2017_Men_SP_Scores.pdf'
    expect(@rake['parse:scores'].invoke).to be_truthy
  end
end 
