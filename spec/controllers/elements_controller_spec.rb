require 'rails_helper'

RSpec.describe ElementsController, type: :controller do
  render_views
  
  let!(:elem4T){ create(:element) }
  let!(:elem4T3T){ create(:element, :combination) }
  let!(:elemLSp){ create(:element, :spin) }
  
  describe '#index' do
    describe 'all' do
      subject { get :index }
      it { is_expected.to be_success }
    end
  end

  describe '#lists' do
    describe 'all' do
      subject { get :list, xhr: true }
      its(:body) { is_expected.to include(elem4T.name) }
      its(:body) { is_expected.to include(elem4T3T.name) }
      its(:body) { is_expected.to include(elemLSp.name) }
    end
    datatable = ElementsDatatable.new
    
    describe "filters:" do
      datatable.filter_keys.each do |key|
        next if key == :goe  # TODO
        it key do
          expect_filter(elem4T, elemLSp, key)
        end
      end
      context 'element name with perfect match' do
        subject { get :list, xhr: true, params: {name: '4T', perfect_match: 'PERFECT_MATCH'} }
        its(:body) { is_expected.to include(elem4T.name) }
        its(:body) { is_expected.not_to include(elem4T3T.name) }
      end
      context 'comparison goe by' do
        context '>' do
          subject { get :list, xhr: true, params: {goe: '1', goe_operator: '>'} }
          its(:body) { is_expected.to include(elem4T.name) }
          its(:body) { is_expected.not_to include(elemLSp.name) }
        end
        context '<' do
          subject { get :list, xhr: true, params: {goe: '1', goe_operator: '<'} }
          its(:body) { is_expected.not_to include(elem4T.name) }
          its(:body) { is_expected.to include(elemLSp.name) }
        end
      end
    end
    describe 'sort:' do
      #datatable.column_names.each do |key|
      [:level].each do |key|
        it key do
          expect_order(elem4T, elemLSp, key)
        end
      end
    end
  end
end
