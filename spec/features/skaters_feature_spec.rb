require 'rails_helper'

RSpec.configure do |c|
  c.filter_run_excluding feature: true
end

feature SkatersController, type: :feature, feature: true do
  let!(:main) { create(:score).skater }
  let!(:sub) { create(:score, :finlandia).skater }
  let(:index_path) { skaters_path }
  
  ################
  feature "#index", js: true do
    context 'index' do
      subject { visit index_path; page }
      it_behaves_like :both_main_sub
    end
    
    context 'search' do
      {name: :fill_in, category: :select, nation: :select}.each do |key, value|
        context key do
          subject { ajax_action(key: key, value: main.send(key), input_type: value, path: index_path) }
          it_behaves_like :only_main
        end
      end
    end
    context 'order' do
      SkatersDatatable.new.columns.select(&:orderable).map(&:name).each do |key|
        include_context :ajax_order, key        
      end
    end
  end
end
