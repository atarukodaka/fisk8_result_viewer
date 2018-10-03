require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  render_views

  it 'home' do
    get :index
    expect(response.body).to include('Fisk8 Result Viewer')
    expect(response.body).to include(Settings['about']['name'])
  end
end
