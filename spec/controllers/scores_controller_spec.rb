require 'rails_helper'

RSpec.describe ScoresController, type: :controller do
  render_views
  
  before do
    competition = create(:competition, {cid: "WORLD2017", season: "2016-17", competition_type: "world", city: "Tokyo", country: "JPN"})
    score = competition.scores.create(sid: "WFS17-MEN", competition_name: "World FS 2017", skater_name: "Skater NAME", category: "MEN", segment: "SHORT PROGRAM", nation: "JPN", ranking: 1, skater: create(:skater, {name: "Skater NAME"}))
  end

  describe 'index' do
    it {
      get :index
      expect(response.body).to include('World FS 2017')
    }
  end
  describe 'show' do
    it {
      get :show, params: { sid: Score.last.sid }
      expect(response.body).to include('Skater NAME')
    }
  end
end
