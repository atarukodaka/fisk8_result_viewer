require 'rails_helper'

RSpec.describe ComponentsController, type: :controller do
  render_views
  
  let!(:skater) { create(:skater)}
  let!(:competition) { create(:competition) }
  let!(:short_ss){
    short = competition.scores.create(segment: "SHORT", skater: skater)
    short.components.create(number: 1, name: "Skating Skill", value: 10.0)
  }
  let!(:free_tr){
    free = competition.scores.create(segment: "FREE", skater: skater)
    free.components.create(number: 2, name: "Transitions", value: 9.0)
  }
  
  context 'index' do
    it 'pure index request' do
      get :index
      expect(response).to be_success
    end
=begin
    
    it 'lists SkatingSkill' do
      get :list, xhr: true
      expect(response.body).to include('Skating Skill')
      expect(response.body).to include('10.0')
    end
    it 'filters by segment' do
      get :list, xhr: true, params: { segment: "FREE"}
      expect(response.body).to include('Skating Skill')
      expect(response.body).to include('9.0')
      expect(response.body).not_to include('10.0')
    end
    context 'value comparison' do
      it 'compares by <' do
        get :list, xhr: true, params: { value: "9.5", value_operator: '<'}
        expect(response.body).to include('Skating Skill')
        expect(response.body).to include('9.0')
        expect(response.body).not_to include('10.0')
      end
      it 'compares by <=' do
        get :list, xhr: true, params: { value: "9", value_operator: '<='}
        expect(response.body).to include('Skating Skill')
        expect(response.body).to include('9.0')
        expect(response.body).not_to include('10.0')
      end
      it 'compares by >=' do
        get :list, xhr: true, params: { value: "9", value_operator: '>='}
        expect(response.body).to include('Skating Skill')
        expect(response.body).to include('9.0')
        expect(response.body).to include('10.0')
      end
      it 'compares by =' do
        get :list, xhr: true, params: { value: "9", value_operator: '='}
        expect(response.body).to include('Skating Skill')
        expect(response.body).to include('9.0')
        expect(response.body).not_to include('10.0')
      end
    end
=end
  end
=begin
  context 'sort:' do
    [:competition_name, :category, :segment, :season, :ranking, :skater_name, :nation, :name, :number, :factor, :value].each do |key|
      it key do
        expect_order(short_ss, free_tr, key)
      end
    end
  end
=end
end
