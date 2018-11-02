require 'rails_helper'

RSpec.describe GrandprixesController, type: :controller do
  using StringToModel
  render_views

  context '#index' do
    it {
      url = 'http://www.isuresults.com/events/gp2018/gpsmen.htm'
      WebMock.enable!
      WebMock.stub_request(:get, url).to_return(
        body: File.read((Rails.root.join('spec/fixtures/webmock', 'gp2018-men.htm')).to_s),
        status: 200
      )
      updater = GrandprixUpdater.new
      updater.update(SkateSeason.new('2018-19'), 'MEN'.to_category)

      get :index, params: { category: 'MEN' }
      expect(response).to have_http_status(:success)

      expect(response.body).to have_content('Nathan CHEN')
      expect(response.body).to have_content('Yuzuru HANYU')
    }
  end
end
