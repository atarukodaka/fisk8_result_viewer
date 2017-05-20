require 'rails_helper'
require 'fisk8viewer'

RSpec.configure do |c|
  c.filter_run_excluding updater: true
end

RSpec.describe SkatersController, type: :controller, updater: true do
  render_views
  
  describe 'skater' do 
    it {
      updater = Fisk8Viewer::Updater.new(accept_categories: [:MEN])
      updater.update_skaters
      skater = Skater.find_by(isu_number: 10967)
      updater.update_isu_bio_details(skater)

      get :show, params: {isu_number: 10967}
      expect(response.status).to eq(200)
      expect(response.body).to include('Yuzuru HANYU')
    }
  end
end
