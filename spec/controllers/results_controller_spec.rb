require 'rails_helper'

RSpec.describe ResultsController, type: :controller do
  render_views

  let!(:world_result) {
    create(:result)
  }

  let!(:finlandia_result){
    create(:result, :finlandia)
  }

  describe '#index' do
    describe 'pure index request' do
      subject { get :index }
      it { is_expected.to be_success }
    end
  end

  describe '#list' do
    describe 'all' do
      subject { get :list, xhr: true }
      its(:body) { is_expected.to include(world_result.competition_name) }
    end
    
    datatable = ResultsDatatable.new
    context 'filter: ' do
      datatable.filter_keys.each do |key|
        it key do
          expect_filter(world_result, finlandia_result, key, column: :competition_name)
        end
      end
    end
    context 'sort: ' do
      datatable.column_names.each do |key|
        it key do
          expect_order(world_result, finlandia_result, key, column: :competition_name)
        end
      end
    end
  end
end
