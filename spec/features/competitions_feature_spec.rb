require 'rails_helper'

RSpec.configure do |c|
  c.filter_run_excluding feature: true
end

feature CompetitionsController, type: :feature, feature: true do
  let!(:main) { create(:competition) }
  let!(:sub) { create(:competition, :finlandia) }
  let(:index_path) { competitions_path }

  ################
  feature "#index", js: true do
    context 'index' do
      subject { visit index_path; page }
      it_behaves_like :both_main_sub
    end
    context 'search' do
      { name: :fill_in, site_url: :fill_in, competition_class: :select, competition_type: :select }.each do |key, value|
        context key do
          subject { ajax_action(key: key, value: main.send(key), input_type: value, path: index_path) }
          it_behaves_like :only_main
        end
      end

      include_context :filter_season
    end
    context 'order' do
      CompetitionsDatatable.new.columns.select(&:orderable).map(&:name).each do |key|
        include_context :ajax_order, key
      end
    end
    context 'paging' do
      it {
        page_length = CompetitionsDatatable.new.settings[:pageLength]
        competition = Competition.create
        100.times do |i|
          Competition.create(name: i)
        end
        visit index_path
        expect(page.body).to have_content("Showing 1 to #{page_length}")
        find(:xpath, '//ul[@class="pagination"]/li/a[@data-dt-idx="2"]').click
        ajax_trigger
        expect(page.body).to have_content("Showing #{page_length+1} to #{page_length * 2}")
      }
    end
  end
end
