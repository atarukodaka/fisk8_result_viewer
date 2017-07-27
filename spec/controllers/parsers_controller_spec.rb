require 'rails_helper'

RSpec.configure do |c|
  c.filter_run_excluding parser: true
end

RSpec.describe ParsersController, type: :controller, parser: true do
  render_views

  context 'index' do
    subject { get :index }
    it { is_expected.to be_success }
  end

  context 'competition' do
    subject {
      url = 'http://www.isuresults.com/results/season1617/wc2017/'
      get :competition, params: {url: url}
    }
    it {
      expect(response).to be_success
      expect(response.body).to have_content(url)
    }
  end

  context 'scores' do
    subject {
      url = 'http://www.isuresults.com/results/season1617/wc2017/wc2017_Men_SP_Scores.pdf'
      get :scores, params: {url: url}
    }
    it {
      expect(response).to be_success
      expect(response.body).to have_content(url)
    }
  end
end
