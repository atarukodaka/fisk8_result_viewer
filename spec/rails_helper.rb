require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'capybara/poltergeist'

ActiveRecord::Migration.maintain_test_schema!

################################################################
module AjaxFeatureHelper
=begin
  ## matcher
  RSpec::Matchers.define :appear_before_on_page do |later_content|
    match do |earlier_content|
      body = (respond_to? :page) ? page.body : response.body
      body.index(earlier_content.to_s) < body.index(later_content.to_s)
    end
  end
=end
  
  ## examples  
  shared_examples :only_main do
    it {
      is_expected.to have_content(main.name)
      is_expected.not_to have_content(sub.name)
    }
  end
  shared_examples :only_sub do
    it {
      is_expected.not_to have_content(main.name)
      is_expected.to have_content(sub.name)
    }
  end
  shared_examples :both_main_sub do
    it {
      is_expected.to have_content(main.name)
      is_expected.to have_content(sub.name)
    }
  end
  shared_examples :only_earlier do
    it {
      is_expected.to have_content(earlier.name)
      is_expected.not_to have_content(later.name)
    }
  end
  shared_examples :only_later do
    it {
      is_expected.not_to have_content(earlier.name)
      is_expected.to have_content(later.name)
    }
  end
  shared_examples :order_main_sub do |key, identifer_key: :name|
    it {
      dir = find("#column_#{key}")['class']
      identifers = [main, sub].sort {|a, b| a.send(key) <=> b.send(key)}.map {|d| d.send(identifer_key)}
      identifers.reverse! if dir =~ /sorting_desc/
      expect(identifers.first).to appear_before identifers.second
    }
  end

  ## context
  shared_context :filter_season do
    ## main, sub, index_path requried to declair
    let(:later) { (main.season > sub.season) ? main : sub }
    let(:earlier) { (main.season <= sub.season) ? main : sub }
    
    context "from later" do
      subject { ajax_action(key: :season_from, value: later.season, input_type: :select, path: index_path) }
      it_behaves_like :only_later
        end
    context "to earlier" do
      subject { ajax_action(key: :season_to, value: earlier.season, input_type: :select, path: index_path)}
      it_behaves_like :only_earlier
    end
  end

  shared_context :ajax_order do |key, identifer_key: :name|
    context key do
      subject! { ajax_action(key: "#column_#{key}", input_type: :click, path: index_path) }
      #it { ajax_compare_sorting(main, sub, key: key, identifer_key: identifer_key) }
      it_behaves_like :order_main_sub, key, identifer_key: identifer_key
    end
  end

  ## functions
  def ajax_trigger
    page.evaluate_script("$('table.display').trigger('change')")
    sleep 1
  end
  def ajax_action(path:, input_type: , key:, value: nil)
    visit path
    case input_type
    when :fill_in
      fill_in key, with: value
    when :select
      select value, from: key
    when :click
      find(key).click
    end
    # trigger
    #binding.pry
    ajax_trigger
    page
  end
=begin  
  def ajax_compare_sorting(obj1, obj2, key:, identifer_key: :name)
    dir = find("#column_#{key}")['class']
    identifers = [obj1, obj2].sort {|a, b| a.send(key) <=> b.send(key)}.map {|d| d.send(identifer_key)}
    identifers.reverse! if dir =~ /sorting_desc/
    #expect(page.body.index(identifers.first)).to be < page.body.index(identifers.second)
    expect(identifers.first).to appear_before identifers.second
  end
=end
end  

################################################################
module Helper
  include AjaxFeatureHelper

  ## customized matches

  RSpec::Matchers.define :appear_before do |later_content|
    match do |earlier_content|
      body = (respond_to? :page) ? page.body : response.body
      body.index(earlier_content.to_s) < body.index(later_content.to_s)
    end
  end

  ## filter
  def expect_filter(obj1, obj2, key, column: :name)
    ## only obj1
    get :list, xhr: true, params: {key => obj1.send(key) }
    expect(response.body).to have_content(obj1.send(column))
    expect(response.body).not_to have_content(obj2.send(column))

    get :list, xhr: true, params: filter_params(key, obj1.send(key))
    expect(response.body).to have_content(obj1.send(column))
    expect(response.body).not_to have_content(obj2.send(column))

    ## only obj2
    get :list, xhr: true, params: {key => obj2.send(key) }
    expect(response.body).not_to have_content(obj1.send(column))
    expect(response.body).to have_content(obj2.send(column))

    get :list, xhr: true, params: filter_params(key, obj2.send(key))
    expect(response.body).not_to have_content(obj1.send(column))
    expect(response.body).to have_content(obj2.send(column))
  end 
  ## order
  def expect_order(obj1, obj2, key, column: :name)
    names = [obj1, obj2].sort {|a, b| a.send(key) <=> b.send(key)}.map {|d| d.send(column)}

    get :list, xhr: true, params: sort_params(key, 'asc')
    expect(names.first).to appear_before(names.last)
    
    get :list, xhr: true, params: sort_params(key, 'desc')
    expect(names.last).to appear_before(names.first)
  end

  ################
  def column_number(column_name)
    controller.create_datatable.column_names.index(column_name.to_s).to_i
  end

  def filter_params(column_name, value)
    {columns: {column_number(column_name).to_s => { data: column_name, "search": {"value": value}}}}
    
  end
  def sort_params(column_name, direction = 'asc')
    {order: {"0": { "column": column_number(column_name), "dir": direction}}}
  end
end

################################################################

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  ## poltergeist
  Capybara.javascript_driver = :poltergeist

  ## database cleaner
  require 'database_cleaner'
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end
  
  config.before(:each) do
    DatabaseCleaner.start
  end
  
  config.after(:each) do
    DatabaseCleaner.clean
  end

  ## FactoryBot
  require 'factory_bot_rails'
  config.include FactoryBot::Syntax::Methods
  config.before(:all) do
    FactoryBot.reload
  end

  config.include Helper
end

