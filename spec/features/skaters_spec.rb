require 'rails_helper'

RSpec.configure do |c|
  c.filter_run_excluding feature: true
end

feature SkatersController, type: :feature, feature: true do

  let!(:skater) { create(:skater) }
  let!(:ladies_skater) { create(:skater, :ladies) }
  let!(:score) { create(:score)}
  let!(:finlandia_score) { create(:score, :finlandia) }

  ################
  
  shared_examples :only_men_skater do
    it {
      is_expected.to have_content(skater.name)
      is_expected.not_to have_content(ladies_skater.name)
    }
  end
  ################
  feature "#index", js: true do
    context 'index' do
      subject { visit skaters_path; page }
      it {
        is_expected.to have_content(skater.name)
        is_expected.to have_content(ladies_skater.name)
      }
    end
    context 'search' do
      {name: :fill_in, category: :select, nation: :select}.each do |key, value|
        context key do
          subject { ajax_action(object: skater, key: key, input_type: value, path: skaters_path) }
          it_behaves_like :only_men_skater
        end
      end
    end
    def ajax_compare_sorting(obj1, obj2, key: key)
      dir = find("#column_#{key}")['class']
      names = [obj1, obj2].sort {|a, b| a.send(key) <=> b.send(key)}.map {|d| d.send(:name)}
      names.reverse! if dir =~ /sorting_desc/
      expect(page.body.index(names.first)).to be < page.body.index(names.second)
    end
    context 'order' do
      [:name, :category].each do |key|
        context key do
          subject! {
            ajax_action(object: nil, key: "#column_#{key}", input_type: :click, path: skaters_path)
          }
          it { ajax_compare_sorting(skater, ladies_skater, key: key) }
        end
      end
    end
  end
end
