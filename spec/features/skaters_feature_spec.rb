require 'rails_helper'

RSpec.describe SkatersController, feature: true do
  #render_views
  
  let!(:main) { create(:competition, :world).scores.first.skater }
  let!(:sub) { create(:competition, :finlandia).scores.first.skater }
  let!(:no_scores_skater) { create(:skater, :no_scores) }
  let(:index_path) { skaters_path }

  ################
  feature '#index', js: true do
    context 'all' do
      subject { visit index_path; page }
      it_behaves_like :contains, true, true
    end

    context :filter do
      include_context :filter, SkatersDatatable::Filters.new, excludings: [:having_scores]


      ## TODO: implement having scores
      context :having_scores do
        it {
          visit index_path
          expect(page.text).to have_content(no_scores_skater.name)
          find('#having_scores').click
          sleep 0.3
          expect(page.text).not_to have_content(no_scores_skater.name)
        }
      end

    end
    context :order do
      include_context :order, SkatersDatatable
    end
  end
end
