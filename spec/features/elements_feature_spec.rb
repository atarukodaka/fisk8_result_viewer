require 'rails_helper'

RSpec.configure do |c|
  c.filter_run_excluding feature: true
end

feature ElementsController, type: :feature, feature: true do
  let!(:score_world)  {    create(:competition, :world).scores.first }
  let!(:score_finlandia)  { create(:competition, :finlandia).scores.first }
  let!(:main){ create(:element, :combination, score: score_world) }
  let!(:sub){ create(:element, :spin, score: score_finlandia) }
  let(:index_path) { elements_path }

  ################
  feature '#index', js: true do
    context 'all' do
      subject { visit index_path; page }
      it_behaves_like :both_main_sub
    end
    context 'filter' do
      include_context :scores_filter

      context 'element_name' do
        subject {
          visit index_path
          select '=', from: :name_operator
          fill_in :element_name, with: main.element_name
          find('input#element_name').send_keys :tab
          sleep 1
          page
        }
        it_behaves_like :only_main
      end

      context 'element_type' do
        subject {
          visit index_path
          select main.element_type, from: :element_type
          sleep 1
          page
        }
        it_behaves_like :only_main
      end

      context 'element_subtype' do
        subject {
          visit index_path
          select main.element_subtype, from: :element_subtype
          sleep 1
          page
        }
        it_behaves_like :only_main
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
        it_behaves_like :only_main
      end
    end
    context 'order' do
      ElementsDatatable.new.columns.select(&:orderable).map(&:name).each do |key|
        include_context :ajax_order, key
      end
    end
  end
end
