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
      filters = [
          { name: :name, input_type: :fill_in,  },
          { name: :category_type, input_type: :select },
          { name: :nation, input_type: :select, }
      ]
      include_context :filter, filters
    end
    context :order do
      include_context :order, SkatersDatatable
    end
  end
end
