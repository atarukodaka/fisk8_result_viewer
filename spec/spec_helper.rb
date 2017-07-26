module AjaxFeatureHelper
  ## matcher
  RSpec::Matchers.define :appear_before_on_page do |later_content|
    match do |earlier_content|
      page.body.index(earlier_content.to_s) < page.body.index(later_content.to_s)
    end
  end
  
  ## functions

  def ajax_trigger
    page.evaluate_script("$('table.display').trigger('change')")
    #sleep 1
  end
  def ajax_action(path:, input_type: , key:, value: nil, object: nil)
    visit path
    case input_type
    when :fill_in
      value ||= object.send(key)
      fill_in key, with: value
    when :select
      value ||= object.send(key)
      select value, from: key
    when :click
      find(key).click
    end
    # trigger
    ajax_trigger
    page
  end
  def ajax_compare_sorting(obj1, obj2, key: key, identifer_key: :name)
    dir = find("#column_#{key}")['class']
    identifers = [obj1, obj2].sort {|a, b| a.send(key) <=> b.send(key)}.map {|d| d.send(identifer_key)}
    identifers.reverse! if dir =~ /sorting_desc/
    #expect(page.body.index(identifers.first)).to be < page.body.index(identifers.second)
    expect(identifers.first).to appear_before_on_page identifers.second
  end
end  

################################################################
module Helper
  include AjaxFeatureHelper

  ## customized matches

  RSpec::Matchers.define :appear_before do |later_content|
    match do |earlier_content|
      response.body.index(earlier_content.to_s) < response.body.index(later_content.to_s)
    end
  end

  ## functions
  def expect_to_include(text)
    expect(response.body).to include(text.to_s)
  end
  def expect_not_to_include(text)
    expect(response.body).not_to include(text.to_s)
  end

  ## filter
  def expect_filter(obj1, obj2, key, column: :name)
    ## only obj1
    get :list, xhr: true, params: {key => obj1.send(key) }
    expect_to_include(obj1.send(column))
    expect_not_to_include(obj2.send(column))

    get :list, xhr: true, params: filter_params(key, obj1.send(key))
    expect_to_include(obj1.send(column))
    expect_not_to_include(obj2.send(column))

    ## only obj2
    get :list, xhr: true, params: {key => obj2.send(key) }
    expect_to_include(obj2.send(column))
    expect_not_to_include(obj1.send(column))

    get :list, xhr: true, params: filter_params(key, obj2.send(key))
    expect_to_include(obj2.send(column))
    expect_not_to_include(obj1.send(column))
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
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  ## FactoryGirl
  require 'factory_girl_rails'
  config.include FactoryGirl::Syntax::Methods
  config.before(:all) do
    FactoryGirl.reload
  end
  
  config.include Helper
end

################
## Codecov
require 'simplecov'
require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov
SimpleCov.start do
  add_filter 'spec/updaters/consistency_spec.rb'
  add_filter 'config/initializers/direction.rb'
end

