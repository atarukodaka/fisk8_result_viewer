require 'rails_helper'

feature ComponentsController, type: :feature, feature: true do
  let!(:score_world) { create(:competition, :world).scores.first }
  let!(:score_finlandia) { create(:competition, :finlandia).scores.first }
  let!(:main) { score_world.components.where(number: 1).first }
  let!(:sub) { score_finlandia.components.where(number: 2).first }
  let(:index_path) { components_path }

  ################
  feature '#index', js: true do
    context 'all' do
      subject { visit index_path; page }
      it_behaves_like :contains, true, true
    end
=begin
    context 'filter' do
      include_context :filter, ComponentsDatatable, excludings: [:season_to, :season_from]
      include_context :filter_season

      context 'component_name' do
        subject {
          ajax_action_filter(key: :number, value: 'Skating Skills', input_type: :select, path: index_path)
        }
        it_behaves_like :contains, true, false
      end

      context 'value' do
        subject {
          ajax_actions([{ key: :value_operator, value: '=', input_type: :select },
                        { key: :value, value: main.value, input_type: :fill_in }], path: index_path)
        }
        it_behaves_like :contains, true, false
      end
    end
    context 'order' do
      include_context :order, ComponentsDatatable
    end
=end
  end
end
