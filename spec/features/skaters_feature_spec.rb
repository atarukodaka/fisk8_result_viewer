require 'rails_helper'

RSpec.describe SkatersController, feature: true do
  #let!(:main) { create(:competition, :world).scores.first.skater }
  #let!(:sub) { create(:competition, :finlandia).scores.first.skater }
  let!(:no_scores_skater) { create(:skater, :no_scores) }

  before {
    create(:competition, :world)
    create(:competition, :finlandia)
  }
  ################
  feature '#index', js: true do
    datatable = SkatersDatatable.new
    include_context :contains_all, datatable

    include_context :filters, datatable
    context 'filters' do
      context :having_scores do
        it {
          ajax_actions([key: :having_scores, input_type: :checkbox], path: skaters_path)
          expect(page.text).not_to have_content(no_scores_skater.name)
        }
      end
    end
    include_context :orders, datatable
  end
end
