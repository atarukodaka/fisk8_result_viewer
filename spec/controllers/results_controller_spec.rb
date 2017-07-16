require 'rails_helper'

RSpec.describe ResultsController, type: :controller do
  render_views

  let!(:men_skater) { create(:skater) }
  let!(:ladies_skater) { create(:skater, :ladies) }
  let!(:world_result) {
    create(:competition).results.create(category: "MEN",ranking: 1, skater: men_skater)
  }

  let!(:finlandia_result){
    create(:competition, :finlandia).results.create(category: "LADIES", ranking: 2, skater: ladies_skater)
  }

  context 'index: ' do
    it 'pure index request' do
      get :index
      expect(response).to be_success
    end

    it 'list' do
      get :list, xhr: true
      expect_to_include(world_result.competition_name)
    end

    attrs = [:skater_name, :category, :nation, :competition_name, :competition_class, :competition_type, :season]
      
    context 'filter: ' do
      attrs.each do |key|
        it key do
          expect_filter(world_result, finlandia_result, key, column: :competition_name)
        end
      end
    end
    context 'sort: ' do
      attrs.each do |key|
        it key do
          expect_order(world_result, finlandia_result, key, column: :competition_name)
        end
      end
    end
  end
end
