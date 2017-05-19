require 'rails_helper'

RSpec.describe SkatersController, type: :controller do
  render_views
  
  before do
    skater = create(:skater, {name: "Skater NAME", nation: "JPN", isu_number: 12345})
    competition = create(:competition) do |c|
      c.start_date = "2017-1-1"
      c.end_date = "2017-1-3"
    end
    competition.scores.create(skater: skater, category: "MEN", segment: "SHORT") do |score|
      score.ranking = 1
      score.tss = 100
    end
    competition.scores.create(skater: skater, category: "MEN", segment: "FREE") do |score|
      score.ranking = 2
      score.tss = 200
    end
    competition.category_results.create(skater: skater, category: "MEN") do |cr|
      cr.ranking = 1
      cr.points = 300
    end
  end

  describe 'index' do
    it {
      get :index
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Skater NAME')
    }
    it {
      get :index, params: {nation: "JPN"}
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Skater NAME')
    }
  end
  describe 'show/:isu_number' do
    it {
      get :show, params: { isu_number: 12345 }
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Skater NAME')
      expect(response.body).to include('MEN')    
      expect(response.body).to include('12345')
    }
  end
  describe 'show/:name' do
    it {
      get :show_by_name, params: { name: "Skater NAME"}
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Skater NAME')
      expect(response.body).to include('MEN')
      expect(response.body).to include('12345')
    }
  end
end
