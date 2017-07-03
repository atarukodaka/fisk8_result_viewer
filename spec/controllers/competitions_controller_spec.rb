require 'rails_helper'

module CompetitionsHelper
  def expect_to_include(text)
    expect(response.body).to include(text)
  end
  def expect_not_to_include(text)
    expect(response.body).not_to include(text)
  end
  def expect_to_include_competition(competition)
    [:name, :short_name, :city, :country].each do |key|
      expect(response.body).to include(competition[key])
    end
  end
end  

################################################################
RSpec.describe CompetitionsController, type: :controller do
  include CompetitionsHelper

  render_views

  let!(:world) {
    skater = create(:skater)
    competition = create(:competition)
    cr = competition.category_results.create(skater: skater, category: "MEN", ranking: 1)
    score = competition.scores.create(skater: skater, category: "MEN", segment: "SHORT", ranking: 1, category_result: cr)
    competition
  }
  let!(:finlandia){
    create(:competition, :finlandia)
  }
  ################################################################
  context 'index: ' do
    it do
      get :list, xhr: true
      expect_to_include_competition(world)
      expect_to_include_competition(finlandia)
    end
    {json: 'application/json', csv: 'text/csv'}.each do |format, content_type|
      it format do
        get :index, params: {format: format}
        expect(response.content_type).to eq(content_type)
        expect_to_include_competition(world)
        expect_to_include_competition(finlandia)
      end
    end
  end
  ################
  context 'show: ' do
    it 'short_name' do
      get :show, params: { short_name: "WORLD2017" }
      expect_to_include_competition(world)
    end

    it 'short_name/category' do
      get :show, params: { short_name: "WORLD2017", category: "MEN" }
      expect_to_include_competition(world)
      expect_to_include('MEN')
    end
    
    it 'short_name/category/segment' do
      get :show, params: { short_name: "WORLD2017", category: "MEN", segment: "SHORT" }
      expect_to_include_competition(world)
      expect_to_include('SHORT')
    end
    
    it 'json' do
      get :show, params: { short_name: "WORLD2017", category: "MEN", segment: "SHORT", format: "json" }
      expect(response.content_type).to eq("application/json")
      expect_to_include_competition(world)
    end
  end
  ################
  context 'filters:' do
    [
      {name: "World"},
      {site_url: "http://world2017.isu.org/results/"},
      {competition_type: 'world'},
      {season: '2016-17'},
    ].each do |params|
      it do
        get :list, xhr: true, params: params
        expect_to_include_competition(world)
        expect_not_to_include('Finlandia')
      end
    end
  end
  context 'sort: ' do
    [:name, :start_date, :city].each do |key|
      it "sorts by #{key}" do
        get :list, xhr: true, params: sort_params(key.to_s, 'asc')
        expect('Finlandia').to appear_before('World')
        
        get :list, xhr: true, params: sort_params(key.to_s, 'desc')
        expect('World').to appear_before('Finlandia')
      end
    end
  end
end
