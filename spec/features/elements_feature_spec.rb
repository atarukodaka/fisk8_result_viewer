require 'rails_helper'

feature ElementsController, type: :feature, feature: true do
  let!(:score_world) { create(:competition, :world).scores.first }
  let!(:score_finlandia) { create(:competition, :finlandia).scores.first }
  let!(:main) { score_world.elements.where(element_type: :jump, element_subtype: :solo).first }
  let!(:sub) { score_finlandia.elements.where(element_type: :spin).first }
  let(:index_path) { elements_path }

  ################
  feature '#index', js: true do
    context 'all' do
      subject { visit index_path; page }
      it_behaves_like :contains, true, true
    end
    context 'filter' do
      include_context :filter, ElementsDatatable::Filters.new,
                      excludings: [:season_to, :season_from, :name_operator, :goe_operator]
      include_context :filter_season

      context 'element_name' do
        subject {
          ajax_actions([{ key: :name_operator, value: '=', input_type: :select },
                        { key: :element_name, value: main.element_name, input_type: :fill_in }], path: index_path)
        }
        it_behaves_like :contains, true, false
      end

      context 'element_type' do
        subject {
          ajax_action_filter(key: :element_type, value: main.element_type, input_type: :select, path: index_path)
        }
        it_behaves_like :contains, true, false
      end

      context 'element_subtype' do
        subject {
          ajax_action_filter(key: :element_subtype, value: main.element_subtype, input_type: :select, path: index_path)
        }
        it_behaves_like :contains, true, false
      end

      context 'goe' do
        subject {
          ajax_actions([{ key: :goe_operator, value: '=', input_type: :select },
                        { key: :goe, value: main.goe, input_type: :fill_in }], path: index_path)
        }
        it_behaves_like :contains, true, false
      end
    end
    context 'order' do
      include_context :order, ElementsDatatable
    end
  end
end
