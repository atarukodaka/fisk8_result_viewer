require 'rails_helper'

feature ScoresController, type: :feature, feature: true do
  #let!(:main) { create(:competition, :world).scores.first }
  #let!(:sub) { create(:competition, :finlandia).scores.first }
  before {
    create(:competition, :world)
    create(:competition, :finlandia)
  }


  ################
  feature '#index', js: true do
    datatable = ScoresDatatable.new
    include_context :contains_all, datatable
    include_context :filters, datatable
    include_context :filter_season, datatable
    include_context :orders, datatable
  end
end
