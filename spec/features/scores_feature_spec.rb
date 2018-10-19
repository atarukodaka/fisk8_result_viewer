require 'rails_helper'

feature ScoresController, type: :feature, feature: true do
  let!(:main) { create(:competition, :world).scores.first }
  let!(:sub) { create(:competition, :finlandia).scores.first }
  let(:index_path) { scores_path }

  ################
  feature '#index', js: true do
    context 'all' do
      subject { visit index_path; page }
      it_behaves_like :contains, true, true
    end
    context 'filter' do
      include_context :filter, ScoresDatatable::Filters.new, excludings: [:season_to, :season_from]
      include_context :filter_season
    end
    context 'order' do
      include_context :order, ScoresDatatable
    end
  end
end
