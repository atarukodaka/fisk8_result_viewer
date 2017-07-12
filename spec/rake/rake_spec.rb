require 'rails_helper'
require 'rake'

=begin
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
    @rake[task].reenable
  end
  
  it 'updates skaters' do
    ENV['accept_categories'] = 'LADIES'
    @rake['update:skaters'].invoke

    expect(Skater.count).to be > 0
  end

  context 'update competition' do
    it 'by competitions.yml' do
      ENV['last'] = '3'
      ENV['accept_categories'] = 'MEN'
      @rake['update:competitions'].execute

      binding.pry
      count = Competition.where(site_url: CompetitionList.all.last(3).map(&:url))
      expect(count).to be > 0
      
    end
    it 'by filename' do
      ENV['last'] = '3'
      ENV['accept_categories'] = 'MEN'
      ENV['filename'] ="competitions_junior"
      binding.pry
      expect(@rake['update:competitions'].invoke).to be_truthy
    end
    it 'by filenames' do
      ENV['last'] = '3'
      ENV['accept_categories'] = 'MEN'
      ENV['filenames'] = "competitions_junior,competitions_challenger"
      expect(@rake['update:competitions'].invoke).to be_truthy
    end
    it 'by force' do
      ENV['last'] = '3'
      ENV['accept_categories'] = 'MEN'
      ENV['force'] = '1'
      ENV['filenames="competitions_junior,competitions_challenger"']
      expect(@rake['update:competitions'].invoke).to be_truthy
    end
    
  end
  it 'parses scores' do
    ENV['url'] = 'http://www.isuresults.com/results/season1617/wc2017/wc2017_Men_SP_Scores.pdf'
    expect(@rake['parse:scores'].invoke).to be_truthy
  end
end 
=end
