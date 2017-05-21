require 'rails_helper'

RSpec.describe CompetitionsController, type: :controller do
  render_views
  
  before do
    skater = create(:skater)
    competition = create(:competition, {cid: "WORLD2017", season: "2016-17", competition_type: "world", city: "Tokyo", country: "JPN"})
    cr = competition.category_results.create(skater: skater, category: "MEN", ranking: 1)
    score = competition.scores.create(skater: skater, category: "MEN", segment: "SHORT", ranking: 1)
  end
  
  ################################################################
  describe 'index' do
    it {
      get :index
      expect(response.status).to eq(200)
      expect(response.body).to include('WORLD2017')
      expect(response.body).to include('Tokyo')
      expect(response.body).to include('JPN')
    }
    it {
      get :index, params: { season: "2016-17"}
      expect(response.body).to include('WORLD2017')
    }
    it {
      get :index, params: { competition_type: "world"}
      expect(response.body).to include('WORLD2017')
    }
    it {
      get :index, params: { competition_type: "gp"}
      expect(response.body).not_to include('WORLD2017')
    }
  end

  describe 'index.json' do
    it {
      get :index, params: {format: :json }
      expect(response.content_type).to eq('application/json')
      expect(response.body).to include('"cid":"WORLD2017"')
      expect(response.body).to include('"city":"Tokyo"')
      expect(response.body).to include('"country":"JPN"')
    }
  end

  describe 'index.csv' do
    it {
      get :index, params: {format: :csv }
      expect(response.content_type).to eq('text/csv')
      expect(response.body).to include('WORLD2017,,Tokyo,JPN,,,,world,2016-17')
    }
  end

  ################
  describe 'show' do
    it {
      get :show, params: { cid: "WORLD2017" }
      expect(response.status).to eq(200)
      expect(response.body).to include('WORLD2017')
      expect(response.body).to include('Tokyo')
      expect(response.body).to include('JPN')
    }
  end

  describe 'show/category' do
    it {
      get :show, params: { cid: "WORLD2017", category: "MEN" }
      expect(response.status).to eq(200)
      expect(response.body).to include('WORLD2017')
      expect(response.body).to include('Tokyo')
      expect(response.body).to include('JPN')
      expect(response.body).to include('MEN')
    }
  end

  describe 'show/category/segment' do
    it {
      get :show, params: { cid: "WORLD2017", category: "MEN", segment: "SHORT" }
      expect(response.status).to eq(200)
      expect(response.body).to include('WORLD2017')
      expect(response.body).to include('Tokyo')
      expect(response.body).to include('JPN')
      expect(response.body).to include('MEN')
      expect(response.body).to include('SHORT')
    }
  end

  describe 'show.json' do
    it {
      get :show, params: { cid: "WORLD2017", category: "MEN", segment: "SHORT", format: "json" }
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
      expect(response.body).to include('Tokyo')
      expect(response.body).to include('JPN')
      expect(response.body).to include('MEN')
      expect(response.body).to include('SHORT')
    }
  end
  
end
