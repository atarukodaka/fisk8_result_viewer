require 'rails_helper'

RSpec.describe SkatersController, type: :controller do
  def expect_to_include_skater(skater)
    [:name, :category, :isu_number].each do |key|
      expect_to_include(skater[key])
    end
  end
  
  render_views

  let!(:men_skater){ create(:skater) }
  let!(:ladies_skater){ create(:skater, :ladies) }
  let!(:no_scores_skater){ create(:skater) {|sk| sk.name = "No SCORES" } }
  let!(:datatable) { controller.create_datatable } 
  before do
    competition = create(:competition)
    cr = create(:category_result, competition: competition, skater: men_skater)
    score = create(:score, competition: competition, skater: men_skater)
    score.elements.create(number: 1, name: "3T", goe: 3, base_value: 10, value: 13)
    score.components.create(number: 1, name: "Skating Skills", value: 9)
    
    score_ladies = create(:score, competition: competition, skater: ladies_skater)
  end
  
  ################################################################
  context 'index: ' do
    it 'pure index request' do
      get :index
      expect(response).to be_success
    end

    it 'list' do
      get :list, xhr: true
      expect_to_include_skater(men_skater)
      expect_to_include_skater(ladies_skater)
      expect_not_to_include('No SCORES')
        
    end
    context 'filters: ' do
      [:name, :category, :nation].each do |key|
        it do
          get :list, xhr: true, params: { key => men_skater.send(key) }
          expect_to_include_skater(men_skater)
          expect_not_to_include(no_scores_skater.name)

          get :list, xhr: true, params: filter_params(key, men_skater.send(key))
          expect_to_include_skater(men_skater)
          expect_not_to_include(no_scores_skater.name)
        end
      end
    end
    context 'sort: ' do
      [:name, :isu_number, :category].each do |key|
        it key do
          names = [men_skater, ladies_skater].sort {|a, b| a.send(key) <=> b.send(key)}.map(&:name)
          get :list, xhr: true, params: sort_params(key, 'asc')
          expect(names.first).to appear_before(names.last)

          get :list, xhr: true, params: sort_params(key, 'desc')
          expect(names.last).to appear_before(names.first)
        end
      end
    end
    context 'format: ' do
      [:json, :csv].each do |format|
        it format do
          get :index, params: { format: format }
          expect_to_include_skater(men_skater)
          expect_to_include_skater(ladies_skater)
        end
      end
    end
  end
  ################################################################
  context 'show: ' do
    it 'isu_number' do
      get :show, params: { isu_number: men_skater.isu_number }
      expect_to_include_skater(men_skater)
    end
    it 'name' do
      get :show, params: { isu_number: men_skater.name }
      expect_to_include_skater(men_skater)
    end
    it 'json' do
      get :show, params: { isu_number: 1, format: 'json' }
      expect(response.content_type).to eq("application/json")
      expect_to_include_skater(men_skater)
    end
  end
end
