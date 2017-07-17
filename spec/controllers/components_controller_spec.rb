require 'rails_helper'

RSpec.describe ComponentsController, type: :controller do
  render_views
  
  let!(:men_skater) { create(:skater)}
  let!(:ladies_skater) { create(:skater, :ladies)}  
  let!(:world) { create(:competition) }
  let!(:finlandia) { create(:competition, :finlandia) }  
  let!(:short_ss){
    short = world.scores.create(category: "MEN", segment: "SHORT", skater: men_skater, ranking: 1)
    short.components.create(number: 1, name: "Skating Skill", factor: 1.0, value: 10.0)
  }
  let!(:free_tr){
    free = finlandia.scores.create(category: "LADIES", segment: "FREE", skater: ladies_skater, ranking: 2)
    free.components.create(number: 2, name: "Transitions", factor: 1.8, value: 9.0)
  }
  
  context 'index' do
    it 'pure index request' do
      get :index
      expect(response).to be_success
    end
    
    it 'lists SkatingSkill' do
      get :list, xhr: true
      expect(response).to be_succes
      expect_to_include(short_ss.name)
    end

    attrs = [:competition_name, :category, :segment, :season, :ranking, :skater_name, :nation, :name, :number, :factor, :value]
    context 'filter: ' do
      attrs.each do |key|
        it key do
          get :list, xhr: true, params: { segment: "SHORT"}
          expect_to_include(short_ss.name)
          expect_not_to_include(free_tr.name)
        end
      end
    end


    context 'sort:' do
#      "#{controller_class.to_s.sub(/Controller/, '')}Datatable".constantize.new
      attrs.each do |key|
        it key do
          expect_order(short_ss, free_tr, key)
        end
      end
    end
    
    context 'value comparison' do
      it 'compares by >' do
        get :list, xhr: true, params: { value: "9.5", value_operator: '>'}
        expect_to_include(short_ss.name)
        expect_not_to_include(free_tr.name)
      end
      it 'compares by <' do
        get :list, xhr: true, params: { value: "9.5", value_operator: '<'}
        expect_to_include(free_tr.name)
        expect_not_to_include(short_ss.name)
      end
      it 'compares by <=' do
        get :list, xhr: true, params: { value: "9", value_operator: '<='}
        expect_to_include(free_tr.name)
        expect_not_to_include(short_ss.name)

      end
      it 'compares by >=' do
        get :list, xhr: true, params: { value: "9", value_operator: '>='}
        expect_to_include(short_ss.name)
        expect_to_include(free_tr.name)
      end
      it 'compares by =' do
        get :list, xhr: true, params: { value: "9", value_operator: '='}
        expect_to_include(free_tr.name)
        expect_not_to_include(short_ss.name)
      end
    end
  end
end
