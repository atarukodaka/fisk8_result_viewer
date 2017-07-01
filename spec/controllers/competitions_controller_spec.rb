require 'rails_helper'

RSpec.describe CompetitionsController, type: :controller do
  render_views
  
  before do
    skater = create(:skater)
    competition = create(:competition)
    cr = competition.category_results.create(skater: skater, category: "MEN", ranking: 1)
    score = competition.scores.create(skater: skater, category: "MEN", segment: "SHORT", ranking: 1, category_result: cr)
    comlpetition2 = create(:competition, :finlandia)
  end
  ################################################################
  context 'index' do
    it {
      #get :index, xhr: true
      get :list, xhr: true
      expect(response.status).to eq(200)
      expect(response.body).to include('WORLD2017')
      expect(response.body).to include('Tokyo')
      expect(response.body).to include('JPN')
      expect(response.body).to include('FIN2015')
    }
    it {
      get :list, params: { season: "2016-17"}, xhr: true
      expect(response.body).to include('WORLD2017')
      expect(response.body).not_to include('FIN2015')
    }
    it {
      get :list, params: { competition_type: "world"}, xhr: true
      expect(response.body).to include('WORLD2017')
      expect(response.body).not_to include('FIN2015')
    }
  end

  describe 'index.json' do
    it {
      get :index, params: {format: :json }
      expect(response.content_type).to eq('application/json')
      expect(response.body).to include('"short_name":"WORLD2017"')
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
      get :show, params: { short_name: "WORLD2017" }
      expect(response.status).to eq(200)
      expect(response.body).to include('WORLD2017')
      expect(response.body).to include('Tokyo')
      expect(response.body).to include('JPN')
    }
  end

  describe 'show/category' do
    it {
      get :show, params: { short_name: "WORLD2017", category: "MEN" }
      expect(response.status).to eq(200)
      expect(response.body).to include('WORLD2017')
      expect(response.body).to include('Tokyo')
      expect(response.body).to include('JPN')
      expect(response.body).to include('MEN')
    }
  end

  describe 'show/category/segment' do
    it {
      get :show, params: { short_name: "WORLD2017", category: "MEN", segment: "SHORT" }
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
      get :show, params: { short_name: "WORLD2017", category: "MEN", segment: "SHORT", format: "json" }
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
      get :list, xhr: true, params: { name: "World" }
      expect(response.body).to include('World FS 2017')
      expect(response.body).not_to include('GP USA 2015')
    end
    it 'filters by site_url' do
      get :list, xhr: true, params: { site_url: "http://world2017.isu.org/results/" }
      expect(response.body).to include('World FS 2017')
      expect(response.body).not_to include('GP USA 2015')
    end
    it 'filters by competition_type' do
      get :list, xhr: true, params: { competition_type: 'world' }
      expect(response.body).to include('World FS 2017')
      expect(response.body).not_to include('GP USA 2015')
    end
    it 'filters by isu_championships' do
      get :list, xhr: true, params: { isu_championships_only: 'true' }
      expect(response.body).to include('World FS 2017')
      expect(response.body).not_to include('GP USA 2015')
    end
    it 'filters by season' do
      get :list, xhr: true, params: { season: '2016-17' }
      expect(response.body).to include('World FS 2017')
      expect(response.body).not_to include('GP USA 2015')
    end
  end
end
