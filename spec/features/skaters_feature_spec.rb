require 'rails_helper'

feature SkatersController, type: :feature, feature: true do
  let!(:main) { create(:competition, :world).scores.first.skater }
  let!(:sub) { create(:competition, :finlandia).scores.first.skater }
  let(:no_scores_skater) { create(:skater, :no_scores) }
  let(:index_path) { skaters_path }

  ################
  feature '#index', js: true do
    context 'all' do
      subject { visit index_path; page }
      it_behaves_like :contains, true, true
    end

    context :filter do
      include_context :filter, SkatersFilter, excludings: [:having_scores]

      context :having_no_scores do
        it {
          visit index_path
          expect(page.text).not_to have_content(no_scores_skater.name)
          find_by_id(:having_scores).click
          sleep 1
          expect(page.text).to have_content(no_scores_skater.name)
        }
      end
    end
    context :order do
      include_context :order, SkatersDatatable
    end
  end
end
