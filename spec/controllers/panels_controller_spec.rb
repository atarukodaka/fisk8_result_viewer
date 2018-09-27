require 'rails_helper'

describe PanelsController, type: :controller do
  render_views

  let!(:world){
    create(:competition, :world)
  }
  let!(:john){
    world.performed_segments.first.officials.first.panel
  }
  let!(:mike){
    world.performed_segments.first.officials.second.panel
  }
  
  describe '#index' do
    subject { get :index }
    it { is_expected.to be_success}
  end
  describe '#list' do
    describe 'all' do
      subject { get :list, xhr: true }
      its(:body) { is_expected.to include(john.name) }
      its(:body) { is_expected.to include(mike.name) }
    end

    datatable = PanelsDatatable.new
    describe 'filter: ' do
      datatable.columns.select(&:searchable).map(&:name).each do |key|
        it key do
          expect_filter(john, mike, key)
        end
      end
    end
    describe 'sort: ' do
      datatable.columns.select(&:orderable).map(&:name).each do |key|
        it key do
          expect_order(john, mike, key)
        end
      end
    end
  end
  
  ################
  describe '#show' do
    context 'name' do
      subject { get :show, params: { name: john.name } }
      its(:body) { is_expected.to include(john.name) }
    end

    context 'format: .json' do
      subject { get :show, params: { name: john.name, format: :json } }
      its(:body) { is_expected.to include(john.name) }
    end
  end
end
