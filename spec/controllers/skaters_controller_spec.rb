require 'rails_helper'

RSpec.describe SkatersController, type: :controller do
  render_views

  let!(:men_skater) {
    create(:competition, :world)
      .scores.joins(:category).where("categories.category_type": 'MEN').first.skater
  }
  let!(:ladies_skater) {
    create(:competition, :finlandia)
      .scores.joins(:category).where("categories.category_type": 'LADIES').first.skater
  }
  let!(:no_scores_skater) { create(:skater, :men) { |sk| sk.name = 'Bench WARMER' } }

  ################
  describe '#index' do
    shared_examples :skaters_who_have_scores do
      its(:body) { is_expected.to include(men_skater.name) }
      its(:body) { is_expected.to include(ladies_skater.name) }
      its(:body) { is_expected.not_to include(no_scores_skater.name) }
    end

    describe 'all' do
      subject { get :index }
      it { is_expected.to be_success }
      it_behaves_like :skaters_who_have_scores
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
  ################
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
