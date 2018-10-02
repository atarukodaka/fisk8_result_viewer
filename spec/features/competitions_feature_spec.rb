require 'rails_helper'

RSpec.configure do |c|
  c.filter_run_excluding feature: true
end

feature CompetitionsController, type: :feature, feature: true do
  let!(:main) { create(:competition, :world) }
  let!(:sub) { create(:competition, :finlandia) }
  let(:index_path) { competitions_path }

  ################
  feature '#index', js: true do
    context 'all' do
      subject { visit index_path; page }
      it_behaves_like :both_main_sub
    end
    context 'filter' do
      [{ name: :name, input_type: :fill_in, },
       { name: :site_url, input_type: :fill_in, },
       { name: :competition_class, input_type: :select, },
       { name: :competition_type, input_type: :select, },
      ].each do |hash|
        include_context :ajax_filter, hash[:name], hash[:input_type]
      end

      include_context :filter_season
    end
    context 'order' do
      CompetitionsDatatable.new.columns.select(&:orderable).map(&:name).each do |key|
        include_context :ajax_order, key
      end
    end
  end
end
