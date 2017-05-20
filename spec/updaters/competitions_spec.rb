require 'rails_helper'
require 'fisk8viewer'

RSpec.configure do |c|
  c.filter_run_excluding updater: true
end

describe 'update competition', updater: true do
  subject (){
  }

  it {
    url = 'http://www.isuresults.com/results/season1617/wc2017/'
    updater = Fisk8Viewer::Updater.new
    updater.update_competition(url)

    get :index
    expect(response.status).to eq(200)
  }
  
end
