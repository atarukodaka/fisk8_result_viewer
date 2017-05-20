require 'rails_helper'
require 'fisk8viewer'

RSpec.configure do |c|
  c.filter_run_excluding updater: true
end

RSpec.describe CompetitionsController, type: :controller, updater: true do
  render_views
  
  describe 'update competition: isu generic' do 
    it {
      url = 'http://www.isuresults.com/results/season1617/wc2017/'
      updater = Fisk8Viewer::Updater.new(accept_categories: [:MEN])
      updater.update_competition(url)

      get :index
      expect(response.status).to eq(200)
      expect(response.body).to include('ISU World Figure Skating Championships 2017')
    }
  end

  describe 'update competition: isu generic mdy' do 
    it {
      url = 'http://www.isuresults.com/results/jgpfra2010/'
      updater = Fisk8Viewer::Updater.new(accept_categories: [:MEN])
      updater.update_competition(url, parser_type: :isu_generic_mdy)

      get :index
      expect(response.status).to eq(200)
      expect(response.body).to include(url)
    }
  end

  ################
  describe 'update competitions' do 
    it {
      updater = Fisk8Viewer::Updater.new(accept_categories: [:MEN])    
      items = updater.load_competition_list(File.join(Rails.root, "config/competitions.yaml"))
      items = [items.first]
      updater.update_competitions(items)
      item = items.first
      url = (item.class == Hash) ? item[:url] : item
      
      get :index
      expect(response.status).to eq(200)
      expect(response.body).to include(url)
    }
  end

  
end
