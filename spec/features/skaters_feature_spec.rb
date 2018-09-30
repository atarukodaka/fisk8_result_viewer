require 'rails_helper'

RSpec.configure do |c|
  c.filter_run_excluding feature: true
end

feature SkatersController, type: :feature, feature: true do
  let!(:main) { create(:competition, :world).scores.first.skater }
  let!(:sub) { create(:competition, :finlandia).scores.first.skater }
  let(:index_path) { skaters_path }
  
  ################
  feature "#index", js: true do
    context 'all' do
      subject { visit index_path; page }
      it_behaves_like :both_main_sub
    end
    
    context 'filter' do
      {name: :fill_in, nation: :select}.each do |column_name, input_type|   ## TODO: category
        context column_name do
          subject { ajax_action_filter(key: column_name, value: main.send(column_name), input_type: input_type, path: index_path) }
          it_behaves_like :only_main
        end
      end
=begin
      context :category do
        subject { binding.pry; ajax_action_filter(key: :category, value: main.category.name, input_type: :select, path: index_path) }
        it_behaves_like :only_main
      end
=end
    end
    context 'order' do
      SkatersDatatable.new.columns.select(&:orderable).map(&:name).each do |key|
        include_context :ajax_order, key        
      end
    end
  end
end
