require 'rails_helper'

feature CompetitionsController, type: :feature, feature: true do
  let!(:main) { create(:competition, :world) }
  let!(:sub) { create(:competition, :finlandia) }
  let(:index_path) { competitions_path }

  ################
  feature '#index', js: true do
    context 'all' do
      subject { visit index_path; page }
      it_behaves_like :contains, true, true
    end
    context 'filter' do
      filters = [{ name: :competition_name, input_type: :fill_in, },
       { name: :site_url, input_type: :fill_in, },
       { name: :competition_class, input_type: :select, },
       { name: :competition_type, input_type: :select, },
      ]
      include_context :filter, filters
      include_context :filter_season
    end
    context 'order' do
      include_context :order, CompetitionsDatatable
    end
    context 'paging' do
      it {
        page_length = CompetitionsDatatable.new.settings[:pageLength]
        100.times do |i|
          create(:competition, name: i, short_name: i)
        end
        visit index_path
        expect(page.body).to have_content("Showing 1 to #{page_length}")
        find(:xpath, '//ul[@class="pagination"]/li/a[@data-dt-idx="2"]').click
        sleep 1
        expect(page.body).to have_content("Showing #{page_length+1} to #{page_length * 2}")
      }
    end

  end
end
