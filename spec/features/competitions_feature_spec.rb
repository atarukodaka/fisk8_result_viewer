require 'rails_helper'

RSpec.configure do |c|
  c.filter_run_excluding feature: true
end

feature CompetitionsController, type: :feature, feature: true do
  let!(:world) { create(:competition) }
  let!(:finlandia) { create(:competition, :finlandia) }

  ################
  
  shared_examples :only_world do
    it {
      is_expected.to have_content(world.name)
      is_expected.not_to have_content(finlandia.name)
    }
  end
  shared_examples :only_finlandia do
    it {
      is_expected.not_to have_content(world.name)
      is_expected.to have_content(finlandia.name)
    }
  end
  ################
  feature "#index", js: true do
    context 'index' do
      subject { visit competitions_path; page }
      it {
        is_expected.to have_content(world.name)
        is_expected.to have_content(finlandia.name)
      }
    end
    context 'search' do
      {
        name: :fill_in, site_url: :fill_in, competition_class: :select, competition_type: :select,
      }.each do |key, value|
        context key do
          subject { ajax_action(object: world, key: key, input_type: value, path: competitions_path) }
          it_behaves_like :only_world
        end
      end

      context "season" do
        context "from world" do
          subject {
            ajax_action(object: world, key: :season_from, value: world.season, input_type: :select, path: competitions_path)
          }
          it_behaves_like :only_world
        end
        context "to finlandia" do
          subject {
            ajax_action(object: world, key: :season_to, value: finlandia.season, input_type: :select, path: competitions_path)
          }
          it_behaves_like :only_finlandia
        end
      end
    end
    context 'order' do
      SkatersDatatable.new.datatable.select(&:searchable).map(&:name).each do |key|
        context key do
          subject! {
            ajax_action(key: "#column_#{key}", input_type: :click, path: competitions_path)
          }
          it { ajax_compare_sorting(world, finlandia, key: key) }
        end
      end
    end
  end
end
