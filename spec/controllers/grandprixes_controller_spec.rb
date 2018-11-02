require 'rails_helper'

RSpec.describe GrandprixesController, type: :controller do
  render_views

  context '#index' do
    it {
      get :index
      expect(response).to have_http_status(:success)
    }
  end
end
