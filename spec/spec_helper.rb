module Helper
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
    #Columns.new(controller.columns).names.index(column_name.to_s).to_i    
    #datatable = "#{controller.controller_name.camelize}IndexDatatable".constantize.new
  end
  def filter_params(column_name, value)
    #{ "sSearch_#{column_number(column_name)}" => value }
    {columns: {column_number(column_name).to_s => { data: column_name, "search": {"value": value}}}}
    
  end
  def sort_params(column_name, direction = 'asc')
    #{ iSortCol_0: column_number(column_name), sSortDir_0: direction}
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
## customized matches

RSpec::Matchers.define :appear_before do |later_content|
  match do |earlier_content|
    response.body.index(earlier_content.to_s) < response.body.index(later_content.to_s)
  end
end

## coveralls
=begin
require 'coveralls'
Coveralls.wear!

require 'simplecov'
require 'coveralls'

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start do
  add_filter 'spec/'
  add_filter 'lib/fisk8viewer'
  add_filter 'app/controllers/feedback_controller.rb'
end
=end

require 'simplecov'
require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov
SimpleCov.start do
  add_filter 'spec/updaters/consistency_spec.rb'
  add_filter 'config/initializers/direction.rb'
end

