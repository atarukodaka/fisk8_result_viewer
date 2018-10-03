require 'rails_helper'

feature SkatersController, type: :feature, feature: true do
  let!(:main) { create(:competition, :world).scores.first.skater }
  let!(:sub) { create(:competition, :finlandia).scores.first.skater }
  let(:index_path) { skaters_path }

  ################
  feature '#index', js: true do
    context 'all' do
      subject { visit index_path; page }
      it_behaves_like :contains, true, true
    end

    context :filter do
      include_context :filter, SkatersFilter
    end
    context :order do
      include_context :order, SkatersDatatable
    end
  end
end
