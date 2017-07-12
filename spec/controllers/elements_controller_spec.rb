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
    score1.elements.create(name: "4T+3T", base_value: 13.0, goe: 2.0, value: 14.0)
  }
  let!(:score2){
    create(:competition, :finlandia).scores.create(skater: create(:skater, :ladies), category: 'LADIES', segment: "FREE", ranking: 2)
  }
  let!(:elem3Lz){
    score2.elements.create(name: "3Lz", base_value: 9.0, goe: -1.0, value: 8.0)
  }
  let!(:elem3Lz2T){
    score2.elements.create(name: "3Lz+2T", base_value: 12.0, goe: -2.0, value: 10)
  }
  
  context 'index' do
    it 'pure index request' do
      get :index
      expect(response).to be_success
    end

    it 'lists' do
      get :list, xhr: true
      [elem4T, elem4T3T, elem3Lz, elem3Lz2T].each do |elem|
        expect_to_include(elem.name)
      end
    end
    attrs = [:competition_name, :category, :segment, :season, :skater_name, :nation, :name]  ## MEMO: integer columns doesnt work for filter param
    context "filter" do
      context 'filter' do
        attrs.each do |key|
          it key do
            expect_filter(elem4T, elem3Lz, key)
          end
        end
      end
      it 'filters by element name with perfect match' do
        get :list, xhr: true, params: {name: '4T', perfect_match: 'PERFECT_MATCH'}
        expect_to_include(elem4T.name)
        expect_not_to_include(elem4T3T.name)
      end
      it 'filters by comparison of goe by >' do
        get :list, xhr: true, params: {goe: '1', goe_operator: '>'}
        expect_to_include(elem4T.name)
        expect_not_to_include(elem3Lz2T.name)
      end
      it 'filters by comparison of goe by <' do
        get :list, xhr: true, params: {goe: '1', goe_operator: '<'}
        expect_not_to_include(elem4T.name)
        expect_to_include(elem3Lz2T.name)
      end
=begin
      it 'filters by isu_championships' do
        get :list, xhr: true, params: { isu_championships_only: 'true' }
        expect(response.body).to include('4T')
        expect(response.body).not_to include('3Lz')
      end
=end
    end
    context 'sort:' do
      attrs.each do |key|
        it key do
          expect_order(elem4T3T, elem3Lz, key)
        end
      end
    end
  end
end
