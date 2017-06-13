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
  
  it 'updates skaters' do
    ENV['accept_categories'] = 'LADIES'
    @rake['update:skaters'].invoke

    expect(Skater.count).to be > 0
  end
  
  it 'updates competition' do
    ENV['url'] = 'http://www.isuresults.com/results/season1617/wc2017/'
    expect(@rake['update:competition'].invoke).to be_truthy
    
    expect(Competition.count).to be > 0
    expect(Competition.find_by(site_url: ENV['url'])).to be_truthy
  end

  it 'updates competitions' do
    ENV['last'] = '3'
    ENV['accept_categories'] = 'MEN'
    expect(@rake['update:competitions'].invoke).to be_truthy
  end

  it 'parses scores' do
    ENV['url'] = 'http://www.isuresults.com/results/season1617/wc2017/wc2017_Men_SP_Scores.pdf'
    binding.pry
    expect(@rake['parse:scores'].invoke).to be_truthy
  end
end 
