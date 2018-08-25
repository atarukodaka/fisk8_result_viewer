require 'rails_helper'

RSpec.describe SkatersController, type: :controller do
  render_views

  let!(:men_skater){
    create(:skater) do |skater|
      competition = create(:competition)
      cr = create(:category_result, competition: competition, skater: skater)
      score = create(:score, competition: competition, skater: skater)
      score.elements.create(number: 1, name: "3T", goe: 3, base_value: 10, value: 13)
      score.components.create(number: 1, name: "Skating Skills", value: 9)
    end
  }
  let!(:ladies_skater){
    create(:skater, :ladies) do |skater| 
      create(:score, competition: create(:competition), skater: skater)
    end
  }
  let!(:no_scores_skater){ create(:skater) {|sk| sk.name = "Bench WARMER" } }

  ################################################################
  describe '#index' do
    subject { get :index }
    it { is_expected.to be_success }
  end

  describe '#list' do
    shared_examples :skaters_who_have_scores do
      its(:body) { is_expected.to include(men_skater.name) }
      its(:body) { is_expected.to include(ladies_skater.name) }
      its(:body) { is_expected.not_to include(no_scores_skater.name) }
    end

    describe 'having scores' do
      subject { get :list, xhr: true }
      it_behaves_like :skaters_who_have_scores
    end
    
    datatable = SkatersDatatable.new
    describe 'filters: ' do
      datatable.columns.select(&:searchable).map(&:name).each do |key|
        it key do
          expect_filter(men_skater, ladies_skater, key)
        end
      end
    end
    describe 'sort: ' do
        datatable.column_names.each do |key|
        it key do
          expect_order(men_skater, ladies_skater, key)
        end
      end
    end
    describe 'format: ' do
      [:json, :csv].each do |format|
        context ".#{format}" do
          subject { get :index, params: { format: format } }
          it_behaves_like :skaters_who_have_scores
        end
      end
    end
  end
  ################################################################
  describe '#show' do
    subject { get :show, params: { isu_number: men_skater.isu_number } }
    shared_examples :men_skater do
      its(:body) { is_expected.to include(men_skater.name) }
    end

    context 'isu_number' do
      subject { get :show, params: { isu_number: men_skater.isu_number } }
      it_behaves_like :men_skater
#      its(:body) { is_expected.to include("_plot.png") }  ## score graphs
    end
    context 'name' do
      subject { get :show, params: { isu_number: men_skater.name } }
      it_behaves_like :men_skater
    end
    context 'format: .json' do
      subject { get :show, params: { isu_number: men_skater.isu_number, format: :json } }
      its(:content_type) { is_expected.to eq("application/json") }
      it_behaves_like :men_skater
    end
  end
end
