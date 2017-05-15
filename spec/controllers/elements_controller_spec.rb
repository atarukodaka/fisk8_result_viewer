require 'rails_helper'

RSpec.describe ElementsController, type: :controller do
  render_views
  
  before do
    skater = Skater.create
    score = Competition.create(cid: "CID").scores.create(sid: "SID-elem", skater: skater)
    score.elements.create(element: "4T", base_value: 15.0)
    score.elements.create(element: "4T+3T", base_value: 10.0)
  end
  after do
    Score.all.map(&:destroy)
  end

  describe 'index' do
    it {
      get :index
      expect(response.body).to include('4T')
      expect(response.body).to include('4T+3T')
    }
    it {
      get :index, params: {element: '4T'}
      expect(response.body).to include('4T')
      expect(response.body).not_to include('4T+3T')
    }
    it {
      get :index, params: {element: '4T', partial_match: true}
      expect(response.body).to include('4T')
      expect(response.body).to include('4T+3T')
    }
  end
end
