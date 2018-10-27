require 'rails_helper'
require 'controller_spec_helper'

describe DeviationsController, type: :controller do
  render_views

  let!(:first) {
    competition = create(:competition, :world)
    score = competition.scores.first
    official = score.performed_segment.officials.first
    create(:deviation, :first, score: score, official: official)
  }
  let!(:second) {
    competition = create(:competition, :finlandia)
    score = competition.scores.first
    official = score.performed_segment.officials.first
    create(:deviation, :second, score: score, official: official)
  }

  describe '#index' do
    datatable = DeviationsDatatable.new
    include_context :contains_all, datatable
    [:json, :csv].each do |format|
      include_context :format_response, datatable, format: format
    end
  end

  ################
  describe '#panel_deviation' do
    let!(:panel) { Panel.first }

    context 'panel_name' do
      subject { get :show_panel, params: { name: panel.name } }
      its(:body) { is_expected.to have_content(panel.name) }
    end

    context 'format: .json' do
      subject { get :show_panel, params: { name: panel.name, format: :json } }
      its(:body) { is_expected.to have_content(panel.name) }
    end
  end

  ################
  describe '#skater_deviation' do
    let!(:skater) { Skater.first }

    context 'skater_name' do
      subject { get :show_skater, params: { name: skater.name } }
      its(:body) { is_expected.to have_content(skater.name) }
    end

    context 'format: .json' do
      subject { get :show_skater, params: { name: skater.name, format: :json } }
      its(:body) { is_expected.to have_content(skater.name) }
    end
  end
end
