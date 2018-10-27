# coding: utf-8
require 'rails_helper'

feature ElementsController, type: :feature, feature: true do
  let!(:score_world) { create(:competition, :world).scores.first }
  let!(:score_finlandia) { create(:competition, :finlandia).scores.first }
  let!(:main) { score_world.elements.where(element_type: :jump, element_subtype: :solo).first }
  let!(:sub) { score_finlandia.elements.where(element_type: :spin).first }
  let(:index_path) { elements_path }

  ################
  feature '#index', js: true do
    datatable = ElementsDatatable.new
    include_context :contains_all, datatable
    include_context :filters, datatable
    include_context :filter_season, datatable
    
    context 'match element name' do
      it {
        filter = datatable.filters.flatten.find {|d| d.key == :element_name }
        pros = score_world.elements.where(element_type: :jump, element_subtype: :comb).first
        value = pros.name.split(/\+/).first   ## '3Lz'
        actions = [{key: :name_operator, input_type: :select, value: '⊆'},
                   {key: :element_name, input_type: :text_field, value: value}]
        ajax_actions(actions, path: datatable_index_path(datatable))
        table_text = get_datatable(page).text
        expect(table_text).to have_content(pros.name)
      }
    end

    context 'goe operators' do
      filter = datatable.filters.flatten.find {|d| d.key == :goe }
      context 'gt goe' do
        additional_actions = [{ key: :goe_operator, value: '>', input_type: :select }]
        value_func = lambda {|dt, key| dt.data.order("#{dt.columns[key].source} asc").first.send(key) }
        it_behaves_like :filter, filter, additional_actions: additional_actions, pros_operator: :gt, cons_operator: :lteq
      end
      context 'lt goe' do
        additional_actions = [{ key: :goe_operator, value: '<', input_type: :select }]
        value_func = lambda {|dt, key| dt.data.order("#{dt.columns[key].source} desc").first.send(key) }
        it_behaves_like :filter, filter, additional_actions: additional_actions, pros_operator: :lt, cons_operator: :gteq
      end
    end
    include_context :orders, datatable
  end
end
