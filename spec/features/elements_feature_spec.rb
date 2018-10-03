require 'rails_helper'

feature ElementsController, type: :feature, feature: true do
  let!(:score_world)  {    create(:competition, :world).scores.first }
  let!(:score_finlandia)  { create(:competition, :finlandia).scores.first }
  let!(:main){ score_world.elements.where(element_type: :jump, element_subtype: :solo).first }
  let!(:sub){ score_finlandia.elements.where(element_type: :spin).first }
  let(:index_path) { elements_path }

  ################
  feature '#index', js: true do
    context 'all' do
      subject { visit index_path; page }
      it_behaves_like :contains, true, true
    end
    context 'filter' do
      include_context :score_filter

      context 'element_name' do
        subject {
          visit index_path
          select '=', from: :name_operator
          fill_in :element_name, with: main.element_name
          find('input#element_name').send_keys :tab
          sleep 1
          page
        }
        it_behaves_like :contains, true, false
      end

      context 'element_type' do
        subject {
          visit index_path
          select main.element_type, from: :element_type
          sleep 1
          page
        }
        it_behaves_like :contains, true, false
      end

      context 'element_subtype' do
        subject {
          visit index_path
          select main.element_subtype, from: :element_subtype
          sleep 1
          page
        }
        it_behaves_like :contains, true, false
      end

      context 'goe' do
        subject {
          visit index_path
          select '=', from: :goe_operator
          fill_in :goe, with: main.goe
          find('input#goe').send_keys :tab
          sleep 1
          page
        }
        it_behaves_like :contains, true, false
      end
    end
    context 'order' do
      include_context :order, ElementsDatatable
    end
  end
end
