require 'rails_helper'
require_relative 'concerns/index_controller_spec_helper'

describe DeviationsController, type: :controller do
  render_views

  let!(:main) {
    competition = create(:competition, :world)
    score = competition.scores.first
    #official = score.performed_segment.officials.first
    official = competition.officials.where(category: score.category, segment: score.segment).first
    create(:deviation, :first, score: score, official: official)
  }
  let!(:sub) {
    competition = create(:competition, :finlandia)
    score = competition.scores.first
    official = competition.officials.where(category: score.category, segment: score.segment).first
    create(:deviation, :second, score: score, official: official)
  }

  describe '#index' do
    datatable = DeviationsDatatable.new
    include_context :contains_all, datatable
    [:json, :csv].each do |format|
      include_context :format_response, datatable, format: format
    end
  end

  describe '#show' do
    context 'name' do
      subject { get :show, params: { name: main.name } }
      its(:body) { is_expected.to have_content(main.name) }
    end
  end
end
