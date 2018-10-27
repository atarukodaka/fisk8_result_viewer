require 'rails_helper'
require 'ajax_feature_helper'

feature PanelsController, type: :feature, feature: true do
  before {
    create(:competition, :world)
    create(:competition, :finlandia)
  }

  feature '#index', js: true do
    datatable = PanelsDatatable.new
    [:contains_all, :orders, :filters].each do |context|
      include_context context, datatable
    end
  end
end
