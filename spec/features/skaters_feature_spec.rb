require 'rails_helper'

RSpec.configure do |c|
  c.filter_run_excluding feature: true
end

feature SkatersController, type: :feature, feature: true do
  let!(:main) { create(:score).skater }
  let!(:sub) { create(:score, :finlandia).skater }
  let(:index_path) { skaters_path }
  
  ################
  
  shared_examples :only_main do
    it {
      is_expected.to have_content(main.name)
      is_expected.not_to have_content(sub.name)
    }
  end
  ################
  feature "#index", js: true do
    context 'index' do
      subject { visit index_path; page }
      it {
        is_expected.to have_content(main.name)
        is_expected.to have_content(sub.name)
      }
    end
    context 'search' do
      {name: :fill_in, category: :select, nation: :select}.each do |key, value|
        context key do
          subject { ajax_action(object: main, key: key, input_type: value, path: index_path) }
          it_behaves_like :only_main
        end
      end
    end
    context 'order' do
      SkatersDatatable.new.columns.select(&:searchable).map(&:name).each do |key|
        context key do
          subject! {
            ajax_action(key: "#column_#{key}", input_type: :click, path: index_path)
          }
          it { ajax_compare_sorting(main, sub, key: key) }
        end
      end
    end
  end
end
