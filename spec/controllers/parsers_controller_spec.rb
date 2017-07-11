require 'rails_helper'

RSpec.describe ParsersController, type: :controller do
  render_views

  it 'index' do
    get :index
    expect(response).to be_success
  end
  it 'competition' do
    url = 'http://www.isuresults.com/results/season1617/wc2017/'
    get :competition, params: {url: url}
    expect(response).to be_success
    expect_to_include(url)
  end

  it 'scores' do
    url = 'http://www.isuresults.com/results/season1617/wc2017/wc2017_Men_SP_Scores.pdf'
    get :scores, params: {url: url}
    expect(response).to be_success
  end
end
