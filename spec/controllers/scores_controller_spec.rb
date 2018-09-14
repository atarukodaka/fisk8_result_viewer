require 'rails_helper'

RSpec.describe ScoresController, type: :controller do

  render_views

  let!(:world_score) {
    create(:score, skater: create(:skater), competition: create(:competition))
  }

  let!(:finlandia_score){
    create(:score, :finlandia, skater: create(:skater, :ladies), competition: create(:competition, :finlandia))
  }

  describe '#index' do
    subject { get :index }
    it { is_expected.to be_success }
  end

  describe '#list' do
    describe 'all' do
      subject { get :list, xhr: true }
      its(:body) { is_expected.to include(world_score.name) }
      its(:body) { is_expected.to include(finlandia_score.name) }
    end

    datatable = ScoresDatatable.new
    describe 'filter: ' do
      it { expect_filter(world_score, finlandia_score, :category) }
=begin
      datatable.columns.select(&:searchable).map(&:name).each do |key|
        it key do
          expect_filter(world_score, finlandia_score, key)
        end
      end
=end
    end
    describe 'sort: ' do
      datatable.column_names.each do |key|
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
