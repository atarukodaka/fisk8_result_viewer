require 'rails_helper'

RSpec.describe SkatersController, type: :controller do
  render_views
  
  before do
    skater = create(:skater)
    skater2 = create(:skater, :ladies)
    competition = create(:competition)
    cr = create(:category_result, competition: competition, skater: skater)
    score = create(:score, competition: competition, skater: skater)
    score.elements.create(number: 1, name: "3T", goe: 3, base_value: 10, value: 13)
    score.components.create(number: 1, name: "Skating Skills", value: 9)
  end

  describe 'index' do
    it {
      get :list, xhr: true
      expect(response.body).to include('Skater NAME')
    }
    it {
      get :list, xhr: true, params: {nation: "JPN"}
      expect(response.body).to include('Skater NAME')
    }
  end
  describe 'show/:isu_number' do
    it {
      get :show, params: { isu_number: 1 }
      expect(response.body).to include('Skater NAME')
      expect(response.body).to include('MEN')    
      expect(response.body).to include('1')
    }
  end
  describe 'show/:name' do
    it {
      get :show, params: { isu_number: "Skater NAME"}
      expect(response.body).to include('Skater NAME')
      expect(response.body).to include('MEN')
      expect(response.body).to include('1')
    }
  end
  ################
  context 'filters: ' do
    [{name: "Skater"}, {category: "MEN"}, {nation: "JPN"}].each do |params|
      it do
        get :list, xhr: true, params: params
        expect(response.body).to include("Skater")
        expect(response.body).not_to include("Foo")
      end
    end
  end
  ################
  describe 'json' do
    it 'index json' do
      get :index, params: { format: 'json' }
      expect(response.body).to include('Skater NAME')
    end
    it 'show json by isu_number' do
      get :show, params: { isu_number: 1, format: 'json' }
      expect(response.body).to include('Skater NAME')
    end
  end
end
