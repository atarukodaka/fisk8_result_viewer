require 'rails_helper'

feature PanelsController, type: :feature, feature: true do
  let!(:competition) { create(:competition, :world) }

  let(:main) { competition.performed_segments.first.officials.first.panel }
  let(:sub) { competition.performed_segments.first.officials.last.panel }
  let(:index_path) { panels_path }

  feature '#index', js: true do
    datatable = PanelsDatatable.new
    include_context :contains_all, datatable
    include_context :filters, datatable
    include_context :orders, datatable
  end
end
