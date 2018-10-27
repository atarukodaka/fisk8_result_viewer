require 'rails_helper'

feature ScoresController, type: :feature, feature: true do
  before {
    create(:competition, :world)
    create(:competition, :finlandia)
  }
  ################
  feature '#index', js: true do
    datatable = ScoresDatatable.new
    [:contains_all, :orders, :filters, :filter_season].each do |context|
      include_context context, datatable
    end
  end
end
