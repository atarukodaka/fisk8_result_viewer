require 'rails_helper'

RSpec.configure do |c|
  c.filter_run_excluding feature: true
end

feature ScoresController, type: :feature, feature: true do
  let!(:main) { create(:competition, :world).scores.first }
  let!(:sub) { create(:competition, :finlandia).scores.first }
  let(:index_path) { scores_path }

  ################
  feature '#index', js: true do
    context 'all' do
      subject { visit index_path; page }
      it_behaves_like :both_main_sub
    end
    context 'filter' do
      include_context :scores_filter
    end
    context 'order' do
      ScoresDatatable.new.columns.select(&:orderable).map(&:name).each do |key|
        include_context :ajax_order, key
      end
    end
  end
end
