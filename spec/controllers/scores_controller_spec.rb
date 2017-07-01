require 'rails_helper'

RSpec.describe ScoresController, type: :controller do
  render_views
  
  before do
    skater = create(:skater)
    competition = create(:competition)
    score = competition.scores.create(name: "WFS17-MEN", category: "MEN", segment: "SHORT", ranking: 1, skater: skater)

    skater2 = create(:skater, :ladies)
    competition2 = create(:competition, :finlandia)
    score2 = competition2.scores.create(name: "FIN2015-L-F-2", category: "LADIES", segment: "FREE", ranking: 2, skater: skater2)
  end

  context 'score index' do
    it {
      get :list, xhr: true
      expect(response.body).to include('World FS 2017')
    }
    it {
      get :list, xhr: true, params: { skater_name: "Skater NAME" }
      expect(response.body).to include('WFS17-MEN')
      expect(response.body).not_to include('FIN2015-L-F-2')
    }
    it {
      get :list, xhr: true, params: { category: "MEN" }
      expect(response.body).to include('WFS17-MEN')
      expect(response.body).not_to include('FIN2015-L-F-2')
    }
    it {
      get :list, xhr: true, params: { segment: "SHORT" }
      expect(response.body).to include('WFS17-MEN')
      expect(response.body).not_to include('FIN2015-L-F-2')
    }
    it {
      get :list, xhr: true, params: { nation: "JPN" }
      expect(response.body).to include('WFS17-MEN')
      expect(response.body).not_to include('FIN2015-L-F-2')
    }
    it {
      get :list, xhr: true, params: { competition_name: "World FS 2017" }
      expect(response.body).to include('WFS17-MEN')
      expect(response.body).not_to include('FIN2015-L-F-2')
    }
    it {
      get :list, xhr: true, params: { season: "2016-17" }
      expect(response.body).to include('WFS17-MEN')
      expect(response.body).not_to include('FIN2015-L-F-2')
    }
    it 'json' do
      get :list, xhr: true, params: { format: 'json' }
      expect(response.body).to include('Skater NAME')
    end
  end
  describe 'show' do
    it {
      get :show, params: { name: "WFS17-MEN" }
      expect(response.body).to include('Skater NAME')
    }
    it 'json' do
      get :show, params: { name: "WFS17-MEN", format: "json" }
      expect(response.body).to include('Skater NAME')
    end
  end
end
