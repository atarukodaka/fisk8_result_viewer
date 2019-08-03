require 'rails_helper'
require_relative 'concerns/index_feature_helper'

feature ComponentsController, type: :feature, feature: true do
  before {
    create(:competition, :world)
    create(:competition, :finlandia)
  }

  ################
  feature '#index', js: true do
    datatable = ComponentsDatatable.new
    [:contains_all_feature, :orders, :filters, :filter_season].each do |context|
      include_context context, datatable
    end

    context 'value operators' do
      filter = datatable.filters.flatten.find { |d| d.key == :value }
      include_context :filter_with_operator, filter, :value_operator, '>'
      include_context :filter_with_operator, filter, :value_operator, '<'
    end
  end
end
