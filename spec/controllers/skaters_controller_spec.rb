require 'rails_helper'

RSpec.describe SkatersController, type: :controller do
  render_views

  let!(:men_skater){ create(:skater) }
  let!(:ladies_skater){ create(:skater, :ladies) }
  let!(:no_scores_skater){ create(:skater) {|sk| sk.name = "No SCORES" } }
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
      expect_to_include(men_skater.name)
      expect_to_include(ladies_skater.name)
      expect_not_to_include(no_scores_skater.name)
        
    end
    attrs = [:name, :category, :nation]
    context 'filters: ' do
      attrs.each do |key|
        it key do
          expect_filter(men_skater, ladies_skater, key)
        end
      end
    end
    context 'sort: ' do
      attrs.each do |key|
        it key do
          expect_order(men_skater, ladies_skater, key)
        end
      end
    end
    context 'format: ' do
      [:json, :csv].each do |format|
        it format do
          get :index, params: { format: format }
          expect_to_include(men_skater.name)
          expect_to_include(ladies_skater.name)
        end
      end
    end
  end
  ################################################################
  context 'show: ' do
    it 'isu_number' do
      get :show, params: { isu_number: men_skater.isu_number }
      expect_to_include(men_skater.name)
    end
    it 'name' do
      get :show, params: { isu_number: men_skater.name }
      expect_to_include(men_skater.name)
    end
    it 'json' do
      get :show, params: { isu_number: men_skater.isu_number, format: :json }
      expect(response.content_type).to eq("application/json")
      expect_to_include(men_skater.name)
    end
  end
end
