require 'rails_helper'
require 'ajax_feature_helper'

RSpec.describe SkatersController, feature: true do
  let!(:no_scores_skater) { create(:skater, :no_scores) }

  before {
    create(:competition, :world)
    create(:competition, :finlandia)
  }
  ################
  feature '#index', js: true do
    datatable = SkatersDatatable.new
    [:contains_all, :orders, :filters].each do |context|
      include_context context, datatable
    end

    context :filter_having_scores do
      it {
        ajax_actions([key: :having_scores, input_type: :checkbox], path: skaters_path)
        expect(page.text).not_to have_content(no_scores_skater.name)
      }
    end
    end
end
