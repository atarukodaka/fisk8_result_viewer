require 'rails_helper'

feature CompetitionsController, type: :feature, feature: true do
  let!(:main) { create(:competition, :world) }
  let!(:sub) { create(:competition, :finlandia) }
  let(:index_path) { competitions_path }

  ################
  feature '#index', js: true do
    context 'all' do
      subject { visit index_path; page }
      it_behaves_like :contains, true, true
    end
    context 'filter' do
      filters = [{ name: :name, input_type: :fill_in, },
       { name: :site_url, input_type: :fill_in, },
       { name: :competition_class, input_type: :select, },
       { name: :competition_type, input_type: :select, },
      ]
      include_context :filter, filters
      include_context :filter_season
    end
    context 'order' do
      include_context :order, CompetitionsDatatable
    end
  end
end
