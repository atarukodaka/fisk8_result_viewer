require 'rails_helper'

RSpec.describe ScoresController, type: :controller do
  render_views

  let!(:world_score) {
    create(:competition, :world).scores.first
  }

  let!(:finlandia_score){
    create(:competition, :finlandia).scores.first
  }

  ################
  describe '#index' do
    subject { get :index }
    it {is_expected.to be_success }
  end

  describe '#list' do
    describe 'all' do
      subject { get :list, xhr: true }
      its(:body) { is_expected.to include(world_score.name) }
      its(:body) { is_expected.to include(finlandia_score.name) }
    end

    datatable = ScoresDatatable.new
    describe 'filter: ' do
      datatable.columns.select(&:searchable).map(&:name).each do |key|
        it key do
          expect_filter(world_score, finlandia_score, key)
        end
      end
    end
    describe 'sort: ' do
      datatable.columns.select(&:orderable).map(&:name).each do |key|
        it key do
          expect_order(world_score, finlandia_score, key)
        end
      end
    end
  end
  describe '#show ' do
    context 'name' do
      subject { get :show, params: { name: world_score.name } }
      its(:body) { is_expected.to include(world_score.name) }
    end

    context 'format: .json' do
      subject { get :show, params: { name: world_score.name, format: :json } }
      its(:body) { is_expected.to include(world_score.name) }
    end
  end
end
