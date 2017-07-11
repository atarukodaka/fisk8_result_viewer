require 'rails_helper'

RSpec.describe ElementsController, type: :controller do
  render_views
  
  let!(:score1) {
    create(:competition).scores.create(skater: create(:skater), category: 'MEN', segment: "SHORT", ranking: 1)
  }
  let!(:elem4T){
    score1.elements.create(name: "4T", base_value: 15.0, goe: 3.0, value: 18.0)
  }
  let!(:elem4T3T){
    score1.elements.create(name: "4T+3T", base_value: 13.0, goe: -1.0, value: 12)
  }
  let!(:score2){
    create(:competition, :finlandia).scores.create(skater: create(:skater, :ladies), category: 'LADIES', segment: "FREE", ranking: 2)
  }
  let!(:elem3Lz){
    score2.elements.create(name: "3Lz", base_value: 9.0, goe: 2.0, value: 11.0)
  }
  let!(:elem3Lz2T){
    score2.elements.create(name: "3Lz+2T", base_value: 12.0, goe: -1.0, value: 11)
  }
  
  context 'index' do
    it 'pure index request' do
      get :index
      expect(response).to be_success
    end

    it 'lists' do
      get :list, xhr: true
      expect(response.body).to include('4T')
      expect(response.body).to include('4T+3T')
    end
  end
  context 'filter' do
    it 'filters by element name' do
      get :list, xhr: true, params: {name: '4T'}
      expect(response.body).to include('4T')
      expect(response.body).to include('4T+3T')
    end
    it 'filters by element name with perfect match' do
      get :list, xhr: true, params: {name: '4T', perfect_match: 'PERFECT_MATCH'}
      expect(response.body).to include('4T')
      expect(response.body).not_to include('4T+3T')
    end
    it 'filters by comparison of goe by >' do
      get :list, xhr: true, params: {goe: '1', goe_operator: '>'}
      expect(response.body).to include('4T')
      expect(response.body).not_to include('4T+3T')
    end
    it 'filters by skater_name' do
      get :list, xhr: true, params: { skater_name: "Skater NAME" }
      expect(response.body).to include('4T')
      expect(response.body).not_to include('3Lz')
    end
    it 'filters by category' do
      get :list, xhr: true, params: { category: "MEN" }
      expect(response.body).to include('4T')
      expect(response.body).not_to include('3Lz')
    end
    it 'filters by nation' do
      get :list, xhr: true, params: { nation: "JPN" }
      expect(response.body).to include('4T')
      expect(response.body).not_to include('3Lz')
    end
    it 'filters by competition' do
      get :list, xhr: true, params: { competition_name: "World FS 2017" }
      expect(response.body).to include('4T')
      expect(response.body).not_to include('3Lz')
    end
=begin
    it 'filters by isu_championships' do
      get :list, xhr: true, params: { isu_championships_only: 'true' }
      expect(response.body).to include('4T')
      expect(response.body).not_to include('3Lz')
    end
=end
    it 'filters by season' do
      get :list, xhr: true, params: { season: '2016-17'}
      expect(response.body).to include('4T')
      expect(response.body).not_to include('3Lz')
    end
  end
  context 'sort:' do
    [:competition_name, :category, :segment, :season, :ranking, :skater_name, :nation, :name, :base_value, :value].each do |key|
      it key do
        expect_order(elem4T3T, elem3Lz2T, key)
      end
    end
  end
end
