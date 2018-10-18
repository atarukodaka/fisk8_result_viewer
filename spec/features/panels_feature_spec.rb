require 'rails_helper'

feature PanelsController, type: :feature, feature: true do
  let!(:competition) { create(:competition, :world) }

  let(:main) { competition.performed_segments.first.officials.first.panel }
  let(:sub) { competition.performed_segments.first.officials.last.panel }
  let(:index_path) { panels_path }

  feature '#index', js: true do
    context 'all' do
      subject { visit index_path; page }
      it_behaves_like :contains, true, true
    end
    context 'filter' do
      include_context :filter, PanelsDatatable::Filters.new
    end
    context 'order' do
      include_context :order, PanelsDatatable
    end
  end
end
