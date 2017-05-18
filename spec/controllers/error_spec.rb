require 'rails_helper'

RSpec.configure do |c|
  c.filter_run_excluding error_handler: true
end


RSpec.describe SkatersController, type: :controller, error_handler: true do
  render_views
  
  describe 'show' do
    it {
      get :show, params: { isu_number: -1 }
      expect(response).to have_http_status(404)
    }
  end
end

RSpec.describe CompetitionsController, type: :controller, error_handler: true do
  render_views
  
  describe 'show' do
    it {
      get :show, params: { cid: "----------" }
      expect(response).to have_http_status(404)
    }
  end
end

RSpec.describe ScoresController, type: :controller, error_handler: true do
  render_views
  
  describe 'show' do
    it {
      get :show, params: { sid: "----------" }
      expect(response).to have_http_status(404)
    }
  end
end
