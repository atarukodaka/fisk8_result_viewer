require 'rails_helper'

RSpec.describe SkatersController, type: :controller do
  render_views
  
  before do
    skater = Skater.create!(name: "Skater NAME", nation: "JPN", isu_number: 1)
    Competition.create(cid: "WJ").scores.create(skater: skater, sid: "SID")
  end
  after do
    Skater.all.map(&:destroy)
  end

  describe 'index' do
    it {
      get :index
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Skater NAME')
    }
    it {
      get :index, params: {nation: "JPN"}
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Skater NAME')
    }
  end
  describe 'show' do
    it {
      get :show, params: { isu_number: 1 }
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Skater NAME')
    }
  end
  
end
