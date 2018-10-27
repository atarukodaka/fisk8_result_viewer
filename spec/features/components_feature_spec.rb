require 'rails_helper'

feature ComponentsController, type: :feature, feature: true do
  let!(:score_world) { create(:competition, :world).scores.first }
  let!(:score_finlandia) { create(:competition, :finlandia).scores.first }
  let!(:main) { score_world.components.where(number: 1).first }
  let!(:sub) { score_finlandia.components.where(number: 2).first }
  let(:index_path) { components_path }

  ################
  feature '#index', js: true do
    datatable = ComponentsDatatable.new
    include_context :contains_all, datatable
    include_context :filters, datatable
    include_context :filter_season, datatable
    ## TODO: value operator
    include_context :orders, datatable
  end    
end
