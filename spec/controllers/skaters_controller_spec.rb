require 'rails_helper'

RSpec.describe SkatersController, type: :controller do
  render_views

  let!(:men_skater){
    competition = create(:competition, :world)
    competition.scores.where(category: Category.find_by(name: 'TEAM MEN')).first.skater
    #create(:skater, :men) do |skater|
=begin
      competition = create(:competition, :world)
      create(:performed_segment, competition: competition)
      create(:category_result, competition: competition, skater: skater)
      score = create(:score, competition: competition, skater: skater)
=end
    #end
  }
  let!(:ladies_skater){
    competition = create(:competition, :finlandia)
    competition.scores.where(category: Category.find_by(name: 'JUNIOR LADIES')).first.skater
#    create(:skater, :ladies) do |skater|
#      create(:score, competition: create(:competition), skater: skater)
#    end
  }
  let!(:no_scores_skater){ create(:skater, :men) {|sk| sk.name = 'Bench WARMER' } }

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
      datatable.columns.select(&:orderable).map(&:name).each do |key|
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
    shared_examples :men_skater do
      its(:body) { is_expected.to include(men_skater.name) }
    end

    context 'isu' do
      it {
        get :show, params: { isu_number: men_skater.isu_number }
        expect(response.body).to include(men_skater.name)
      }
    end

    context 'isu_number' do
      subject { get :show, params: { isu_number: men_skater.isu_number } }
      it_behaves_like :men_skater
    end
    context 'name' do
      subject { get :show, params: { isu_number: men_skater.name } }
      it_behaves_like :men_skater
    end
    context 'format: .json' do
      subject { get :show, params: { isu_number: men_skater.isu_number, format: :json } }
      its(:content_type) { is_expected.to eq('application/json') }
      it_behaves_like :men_skater
    end
  end
end
