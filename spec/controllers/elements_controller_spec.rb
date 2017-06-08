require 'rails_helper'

RSpec.describe ElementsController, type: :controller do
  render_views
  
  before do
    skater1 = Skater.create(name: "Skater NAME", nation: "JPN")
    comp1 = Competition.create(name: "COMP1", isu_championships: true, season: '2016-17')
    score1 = comp1.scores.create(sid: "SID-elem1", skater: skater1, category: 'MEN')
    score1.elements.create(name: "4T", base_value: 15.0, goe: 3.0)
    score1.elements.create(name: "4T+3T", base_value: 10.0, goe: -2.0)
    
    skater2 = Skater.create(name: "Foo BAR", nation: "USA")
    comp2 = Competition.create(name: "COMP2", isu_championships: false, season: '2015-16')
    score2 = comp2.scores.create(sid: "SID-elem2", skater: skater2, category: 'LADIES')
    score2.elements.create(name: "3Lz", base_value: 9.0, goe: 2.0)
    score2.elements.create(name: "3Lz+2T", base_value: 12.0, goe: -1.0)
  end

  describe 'index' do
    it {
      get :index
      expect(response.body).to include('4T')
      expect(response.body).to include('4T+3T')
    }
    it {
      get :index, params: {name: '4T'}
      expect(response.body).to include('4T')
      expect(response.body).to include('4T+3T')
    }
    it {
      get :index, params: {name: '4T', perfect_match: 'PERFECT_MATCH'}
      expect(response.body).to include('4T')
      expect(response.body).not_to include('4T+3T')
    }
    # compare
    it {
      get :index, params: {goe: '1', goe_operator: '>'}
      expect(response.body).to include('4T')
      expect(response.body).not_to include('4T+3T')
    }
  end
  describe 'filter' do
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
      get :index, params: { competition_name: "COMP1" }
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
