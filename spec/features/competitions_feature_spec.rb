require 'rails_helper'
require_relative 'concerns/index_feature_helper'

feature CompetitionsController, type: :feature, feature: true do
  before {
    create(:competition, :world)
    create(:competition, :finlandia)
  }

  ################
  feature '#index', js: true do
    datatable = CompetitionsDatatable.new
    [:contains_all, :orders, :filters, :filter_season].each do |context|
      include_context context, datatable
    end

    context 'paging' do
      it {
        page_length = CompetitionsDatatable.new.settings[:pageLength]
        100.times do |i|
          create(:competition, name: i, short_name: i, start_date: Date.new(2015, 7, 1))
        end
        visit competitions_path
        expect(page.body).to have_content("Showing 1 to #{page_length}")
        find(:xpath, '//ul[@class="pagination"]/li/a[@data-dt-idx="2"]').click
        sleep 1
        expect(page.body).to have_content("Showing #{page_length + 1} to #{page_length * 2}")
      }
    end
  end
end
