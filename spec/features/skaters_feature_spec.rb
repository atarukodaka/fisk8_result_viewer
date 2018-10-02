require 'rails_helper'

RSpec.configure do |c|
  c.filter_run_excluding feature: true
end

feature SkatersController, type: :feature, feature: true do
  let!(:main) { create(:competition, :world).scores.first.skater }
  let!(:sub) { create(:competition, :finlandia).scores.first.skater }
  let(:index_path) { skaters_path }

  ################
  feature '#index', js: true do
    context 'all' do
      subject { visit index_path; page }
      it_behaves_like :both_main_sub
    end

    context 'filter' do
      filters = [
        { name: :name, input_type: :fill_in,  },
        {
          name:           :category_type,
          input_type:     :select,
          value_function: lambda {|elem| elem.category_type},
        },
        { name: :nation, input_type: :select, }
      ]
      filters.each do |hash|
        include_context :ajax_filter, hash[:name], hash[:input_type], hash[:value_function]
      end
    end
    context 'order' do
      SkatersDatatable.new.columns.select(&:orderable).map(&:name).each do |key|
        include_context :ajax_order, key
      end
    end
=begin
    context 'paging' do
      it {
        page_length = SkatersDatatable.new.settings[:pageLength]
        100.times do |i|
          create(:skater, :men)
        end
        visit index_path
        expect(page.body).to have_content("Showing 1 to #{page_length}")
        find(:xpath, '//ul[@class="pagination"]/li/a[@data-dt-idx="2"]').click
        sleep 1
        expect(page.body).to have_content("Showing #{page_length+1} to #{page_length * 2}")
      }
    end
=end
  end
end
