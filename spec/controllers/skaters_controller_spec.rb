require 'rails_helper'
require 'controller_spec_helper'

RSpec.describe SkatersController, type: :controller do
  using StringToModel

  render_views

  let!(:men_skater) {
    create(:competition, :world)
      .scores.joins(:category).where("categories.category_type": 'MEN'.to_category_type).first.skater
  }
  let!(:ladies_skater) {
    create(:competition, :finlandia)
      .scores.joins(:category).where("categories.category_type": 'LADIES'.to_category_type).first.skater
  }
  let!(:no_scores_skater) { create(:skater, :no_scores) }

  ################
  describe '#index' do
    datatable = SkatersDatatable.new
    include_context :contains_all, datatable
    [:json, :csv].each do |format|
      include_context :format_response, datatable, format: format
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
