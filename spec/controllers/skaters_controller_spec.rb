require 'rails_helper'

RSpec.describe SkatersController, type: :controller do
  render_views
  
  before do
    skater = Skater.create(name: "Skater NAME", nation: "JPN", category: 'MEN', isu_number: 12345)
    skater2 = Skater.create(name: "Foo BAR", nation: "USA", category: 'LADIES', isu_number: 999)
    competition = Competition.create do |c|
      c.cid = "WORLD"
      c.start_date = "2017-1-1"
      c.end_date = "2017-1-3"
    end
    score = competition.scores.create(skater: skater, category: "MEN", segment: "SHORT") do |score|
      score.name = "WORLD-MEN-1"
      score.ranking = 1
      score.tss = 100
    end
    score.elements.create(number: 1, name: "3T", goe: 3, base_value: 10, value: 13)
    score.components.create(number: 1, name: "Skating Skills", value: 9)

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
  ################
  describe 'filter-by' do
    it { 
      get :index, params: {name: "Skater"}
      expect(response.body).to include("Skater")
      expect(response.body).not_to include("Foo")
    }
    it { 
      get :index, params: {category: "MEN"}
      expect(response.body).to include("Skater")
      expect(response.body).not_to include("Foo")
    }
    it { 
      get :index, params: {nation: "JPN"}
      expect(response.body).to include("Skater")
      expect(response.body).not_to include("Foo")
    }
  end
  ################
  describe 'json' do
    it 'index json' do
      get :index, params: { format: 'json' }
      expect(response.body).to include('Skater NAME')
    end
    it 'show json by isu_number' do
      get :show, params: { isu_number: 12345, format: 'json' }
      expect(response.body).to include('Skater NAME')
    end
  end
  
end
