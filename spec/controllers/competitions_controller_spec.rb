require 'rails_helper'

RSpec.describe CompetitionsController, type: :controller do
  render_views
  
  before do
    skater = Skater.create(name: "Skater NAME")
    competition = Competition.create(cid: "WORLD2017", name: "World FS 2017", season: "2016-17", competition_type: "world", city: "Tokyo", country: "JPN", site_url: 'http://world-fs-2017/')
    cr = competition.category_results.create(skater: skater, category: "MEN", ranking: 1)
    score = competition.scores.create(skater: skater, category: "MEN", segment: "SHORT", ranking: 1)
    cr.scores << score

    competition2 = Competition.create(cid: "GPUSA2015", name: 'GP USA 2015', season: "2015-16", competition_type: "gp", city: "NY", country: "USA", site_url: 'http://gp-usa-2015')
  end
  
  ################################################################
  context 'index' do
    it {
      get :index
      expect(response.status).to eq(200)
      expect(response.body).to include('WORLD2017')
      expect(response.body).to include('Tokyo')
      expect(response.body).to include('JPN')
      expect(response.body).to include('GPUSA2015')
    }
    it {
      get :index, params: { season: "2016-17"}
      expect(response.body).to include('WORLD2017')
      expect(response.body).not_to include('GPUSA2015')
    }
    it {
      get :index, params: { competition_type: "world"}
      expect(response.body).to include('WORLD2017')
      expect(response.body).not_to include('GPUSA2015')
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
      expect(response.body).to include('WORLD2017')
      expect(response.body).to include('Tokyo')
      expect(response.body).to include('JPN')
      expect(response.body).to include('world')
      expect(response.body).to include('2016-17')
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
  ################
  describe 'filter' do
    it 'filters by name' do
      get :index, params: { name: "World" }
      expect(response.body).to include('World FS 2017')
      expect(response.body).not_to include('GP USA 2015')
    end
    it 'filters by site_url' do
      get :index, params: { site_url: "world-fs-2017" }
      expect(response.body).to include('World FS 2017')
      expect(response.body).not_to include('GP USA 2015')
    end
    it 'filters by competition_type' do
      get :index, params: { competition_type: 'world' }
      expect(response.body).to include('World FS 2017')
      expect(response.body).not_to include('GP USA 2015')
    end
    it 'filters by season' do
      get :index, params: { season: '2016-17' }
      expect(response.body).to include('World FS 2017')
      expect(response.body).not_to include('GP USA 2015')
    end
  end
end
