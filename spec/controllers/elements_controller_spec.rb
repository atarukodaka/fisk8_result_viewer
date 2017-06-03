require 'rails_helper'

RSpec.describe ElementsController, type: :controller do
  render_views
  
  before do
    score = Competition.create.scores.create(sid: "SID-elem", skater: Skater.create)
    score.elements.create(name: "4T", base_value: 15.0, goe: 3.0)
    score.elements.create(name: "4T+3T", base_value: 10.0, goe: -2.0)
  end

  describe 'index' do
    it {
      get :index
      expect(response.body).to include('4T')
      expect(response.body).to include('4T+3T')
    }
    it {
      get :index, params: {name: '4T'}
      expect(response.body).to include('4T')
      expect(response.body).to include('4T+3T')
    }
    it {
      get :index, params: {name: '4T', perfect_match: 'PERFECT_MATCH'}
      expect(response.body).to include('4T')
      expect(response.body).not_to include('4T+3T')
    }
    # compare
    it {
      get :index, params: {goe: '>1'}
      expect(response.body).to include('4T')
      expect(response.body).not_to include('4T+3T')
    }
  end
end
