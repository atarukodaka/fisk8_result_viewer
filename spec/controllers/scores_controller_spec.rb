require 'rails_helper'

RSpec.describe ScoresController, type: :controller do
  def expect_to_include_score(score)
    expect_to_include(score.name)
  end

  render_views

  let!(:men_skater) { create(:skater) }
  let!(:ladies_skater) { create(:skater, :ladies) }
  let!(:world_score) {
    create(:competition).scores.create(name: "WFS17-MEN", category: "MEN", segment: "SHORT", ranking: 1, skater: men_skater, tss: 300)
  }

  let!(:finlandia_score){
    create(:competition, :finlandia).scores.create(name: "FIN2015-L-F-2", category: "LADIES", segment: "FREE", ranking: 2, skater: ladies_skater, tss: 200)
  }

  context 'index: ' do
    it 'pure index request' do
      get :index
      expect(response).to be_success
    end

    it 'list' do
      get :list, xhr: true
      expect(response.body).to include('World FS 2017')
    end

    context 'filter: ' do
      [:skater_name, :category, :segment, :nation, :competition_name, :season].each do |key|
        it key do
          get :list, xhr: true, params: {key => world_score.send(key)}
          expect_to_include_score(world_score)
          expect_not_to_include(finlandia_score.name)

          get :list, xhr: true, params: filter_params(key, world_score.send(key))
          expect_to_include_score(world_score)
          expect_not_to_include(finlandia_score.name)
        end
      end
    end
    context 'sort: ' do
      [:name, :competition_name, :skater_name, :ranking, :tss].each do |key|
        it "by #{key}" do
          names = [world_score, finlandia_score].sort {|a, b| a.send(key) <=> b.send(key)}.map(&:name)
          get :list, xhr: true, params: sort_params(key, 'asc')
          expect(names.first).to appear_before(names.last)

          get :list, xhr: true, params: sort_params(key, 'desc')
          expect(names.last).to appear_before(names.first)
        end
      end
    end
  end
  context 'show: ' do
    it {
      get :show, params: { name: world_score.name }
      expect_to_include_score(world_score)
    }
    it 'json' do
      get :show, params: { name: world_score.name, format: "json" }
      expect_to_include_score(world_score)
    end
  end
end
