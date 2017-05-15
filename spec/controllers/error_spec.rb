require 'rails_helper'

RSpec.describe SkatersController, type: :controller do
  render_views
  
  describe 'show' do
    it {
      get :show, params: { isu_number: -1 }
      expect(response).to have_http_status(404)
    }
  end
end
RSpec.describe CompetitionsController, type: :controller do
  render_views
  
  describe 'show' do
    it {
      get :show, params: { cid: "----------" }
      expect(response).to have_http_status(404)
    }
  end
end
RSpec.describe ScoresController, type: :controller do
  render_views
  
  describe 'show' do
    it {
      get :show, params: { sid: "----------" }
      expect(response).to have_http_status(404)
    }
  end
end
