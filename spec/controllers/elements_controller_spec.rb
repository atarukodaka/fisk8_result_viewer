require 'rails_helper'

RSpec.describe ElementsController, type: :controller do
  render_views
  
  before do
    score1 = create(:competition).scores.create(skater: create(:skater), category: 'MEN')
    score1.elements.create(name: "4T", base_value: 15.0, goe: 3.0)
    score1.elements.create(name: "4T+3T", base_value: 10.0, goe: -2.0)
    
    score2 = create(:competition, :finlandia).scores.create(skater: create(:skater, :ladies), category: 'LADIES')
    score2.elements.create(name: "3Lz", base_value: 9.0, goe: 2.0)
    score2.elements.create(name: "3Lz+2T", base_value: 12.0, goe: -1.0)
  end
  
  context 'index' do
    it 'lists' do
      get :index
      expect(response.body).to include('4T')
      expect(response.body).to include('4T+3T')
    end
  end
  context 'filter' do
    it 'filters by element name' do
      get :index, params: {name: '4T'}
      expect(response.body).to include('4T')
      expect(response.body).to include('4T+3T')
    end
    it 'filters by element name with perfect match' do
      get :index, params: {name: '4T', perfect_match: 'PERFECT_MATCH'}
      expect(response.body).to include('4T')
      expect(response.body).not_to include('4T+3T')
    end
    it 'filters by comparison of goe by >' do
      get :index, params: {goe: '1', goe_operator: '>'}
      expect(response.body).to include('4T')
      expect(response.body).not_to include('4T+3T')
    end
    it 'filters by skater_name' do
      get :index, params: { skater_name: "Skater NAME" }
      expect(response.body).to include('4T')
      expect(response.body).not_to include('3Lz')
    end
    it 'filters by category' do
      get :index, params: { category: "MEN" }
      expect(response.body).to include('4T')
      expect(response.body).not_to include('3Lz')
    end
    it 'filters by nation' do
      get :index, params: { nation: "JPN" }
      expect(response.body).to include('4T')
      expect(response.body).not_to include('3Lz')
    end
    it 'filters by competition' do
      get :index, params: { competition_name: "World FS 2017" }
      expect(response.body).to include('4T')
      expect(response.body).not_to include('3Lz')
    end
    it 'filters by isu_championships' do
      get :index, params: { isu_championships_only: 'true' }
      expect(response.body).to include('4T')
      expect(response.body).not_to include('3Lz')
    end
    it 'filters by season' do
      get :index, params: { season: '2016-17'}
      expect(response.body).to include('4T')
      expect(response.body).not_to include('3Lz')
    end
  end
end
