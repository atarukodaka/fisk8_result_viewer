require 'rails_helper'
require 'ajax_feature_helper'

feature ElementsController, type: :feature, feature: true do
  before {
    create(:competition, :world)
    create(:competition, :finlandia)
  }
  ################
  feature '#index', js: true do
    datatable = ElementsDatatable.new
    [:contains_all, :orders, :filters, :filter_season].each do |context|
      include_context context, datatable
    end

    context 'match element name' do
      it {
        pros = datatable.data.where(element_type: :jump, element_subtype: :comb).first
        value = pros.name.split(/\+/).first   ## '3Lz'
        actions = [{ key: :name_operator, input_type: :select, value: '⊆' },
                   { key: :element_name, input_type: :text_field, value: value }]
        ajax_actions(actions, path: datatable_index_path(datatable))
        table_text = get_datatable(page).text
        expect(table_text).to have_content(pros.name)
      }
    end

    context 'goe operators' do
      filter = datatable.filters.flatten.find { |d| d.key == :goe }
      include_context :filter_with_operator, filter, :goe_operator, '>'
      include_context :filter_with_operator, filter, :goe_operator, '<'
    end
  end
end
