require 'rails_helper'

RSpec.describe CompetitionsController, type: :controller do
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
    it 'list' do
      get :list, xhr: true
      expect_to_include_competition(world)
      expect_to_include_competition(finlandia)
    end

    context 'filters:' do
      [:name, :site_url, :competition_type, :season].each do |key|
        it key do
          get :list, xhr: true, params: {key => world[key] }
          expect_to_include_competition(world)
          expect_not_to_include('Finlandia')

          get :list, xhr: true, params: filter_params(key, world[key])
          expect_to_include_competition(world)
          expect_not_to_include('Finlandia')
        end
      end
    end
    context 'sort: ' do
      [:name, :start_date, :city].each do |key|
        it "by #{key}" do
          get :list, xhr: true, params: sort_params(key, 'asc')
          expect('Finlandia').to appear_before('World')

          get :list, xhr: true, params: sort_params(key, 'desc')
          expect('World').to appear_before('Finlandia')
        end
      end
    end
    context 'format: ' do
      {json: 'application/json', csv: 'text/csv'}.each do |format, content_type|
        it format do
          get :index, params: {format: format}
          expect(response.content_type).to eq(content_type)
          expect_to_include_competition(world)
          expect_to_include_competition(finlandia)
        end
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
end
