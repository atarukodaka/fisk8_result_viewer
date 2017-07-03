# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

module Helper
  def sort_params(column_name, direction = 'asc')
    datatable = controller.create_datatable
    col_num = datatable.column_names.index(column_name).to_i
    { iSortCol_0: col_num, sSortDir_0: direction}
  end
=begin
  def get_expect_order(column_name: 'name', before: , after: )
    datatable = controller.create_datatable
    col_num = datatable.column_names.index(column_name).to_i
    get :list, xhr: true, params: { iSortCol_0: col_num , sSortDir_0: 'asc'}
    expect(before).to appear_before(after)
    
    get :list, xhr: true, params: { iSortCol_0: col_num , sSortDir_0: 'desc'}
    expect(after).to appear_before(before)
  end

  def get_expect_filter(key:, value:, include:, exclude:)
    get :list, xhr: true, params: {key => value}
    expect(response.body).to include(include)
    expect(response.body).not_to include(exclude)
  end
=end
end

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
    response.body.index(earlier_content) < response.body.index(later_content)
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

