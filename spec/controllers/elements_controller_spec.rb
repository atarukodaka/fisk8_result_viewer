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
      datatable.columns.select(&:searchable).map(&:name).each do |key|
        next if key.to_sym == :goe  # TODO
        it key do
          expect_filter(elem4T, elemLSp, key)
        end
      end
      context 'element name with perfect match' do
        subject { get :list, xhr: true, params: {name: '4T', name_operator: 'eq'} }
        its(:body) { is_expected.to include(elem4T.name) }
        its(:body) { is_expected.not_to include(elem4T3T.name) }
      end
      context 'comparison goe by' do
        context '>' do
          subject { get :list, xhr: true, params: {goe: '1', goe_operator: 'gt'} }
          its(:body) { is_expected.to include(elem4T.name) }
          its(:body) { is_expected.not_to include(elemLSp.name) }
        end
        context '<' do
          subject { get :list, xhr: true, params: {goe: '1', goe_operator: 'lt'} }
          its(:body) { is_expected.not_to include(elem4T.name) }
          its(:body) { is_expected.to include(elemLSp.name) }
        end
      end
    end
    describe 'sort:' do
      datatable.columns.select(&:orderable).map(&:name).each do |key|
        it key do
          expect_order(elem4T, elemLSp, key)
        end
      end
    end
  end
end
