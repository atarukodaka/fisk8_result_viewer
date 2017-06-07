require 'rails_helper'

RSpec.describe ScoresController, type: :controller do
  render_views
  
  before do
    skater = Skater.create(name: "Skater NAME", nation: "JPN")
    competition = Competition.create(cid: "WORLD2017", name: "World FS 2017", season: "2016-17", competition_type: :world, city: "Tokyo", country: "JPN")
    score = competition.scores.create(sid: "WFS17-MEN", category: "MEN", segment: "SHORT", ranking: 1, skater: skater)

    skater2 = Skater.create(name: "Foo BAR", nation: "USA")
    competition2 = Competition.create(cid: "GPUSA2015", name: "GP USA 2015", season: "2015-16", competition_type: "gp", city: "NY", country: "USA")
    score2 = competition2.scores.create(sid: "GPUSA-M", category: "LADIES", segment: "FREE", ranking: 2, skater: skater2)
  end

  describe 'score index' do
    it {
      get :index
      expect(response.body).to include('World FS 2017')
    }
    it {
      get :index, params: { skater_name: "Skater NAME" }
      expect(response.body).to include('WFS17-MEN')
      expect(response.body).not_to include('GPUSA-M')
    }
    it {
      get :index, params: { category: "MEN" }
      expect(response.body).to include('WFS17-MEN')
      expect(response.body).not_to include('GPUSA-M')
    }
    it {
      get :index, params: { segment: "SHORT" }
      expect(response.body).to include('WFS17-MEN')
      expect(response.body).not_to include('GPUSA-M')
    }
    it {
      get :index, params: { nation: "JPN" }
      expect(response.body).to include('WFS17-MEN')
      expect(response.body).not_to include('GPUSA-M')
    }
    it {
      get :index, params: { competition_name: "World FS 2017" }
      expect(response.body).to include('WFS17-MEN')
      expect(response.body).not_to include('GPUSA-M')
    }
    it {
      get :index, params: { season: "2016-17" }
      expect(response.body).to include('WFS17-MEN')
      expect(response.body).not_to include('GPUSA-M')
    }
  end
  describe 'show' do
    it {
      get :show, params: { sid: "WFS17-MEN" }
      expect(response.body).to include('Skater NAME')
    }
  end
  describe 'show.json' do
    it {
      get :show, params: { sid: "WFS17-MEN", format: "json" }
      expect(response.body).to include('Skater NAME')
    }
  end
end
