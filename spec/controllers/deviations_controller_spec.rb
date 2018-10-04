require 'rails_helper'

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
    subject { get :index  }
    it { is_expected.to be_success}
    its(:body) { is_expected.to have_content(first.score.name) }
    its(:body) { is_expected.to have_content(second.score.name) }
  end

  ################
  describe '#panel_deviation' do
    let!(:panel) { Panel.first }

    context 'panel_name' do
      subject { get :panel, params: { name: panel.name } }
      its(:body) { is_expected.to have_content(panel.name) }
    end

    context 'format: .json' do
      subject { get :panel, params: { name: panel.name, format: :json } }
      its(:body) { is_expected.to have_content(panel.name) }
    end
  end

  ################
  describe '#skater_deviation' do
    let!(:skater) { Skater.first }

    context 'skater_name' do
      subject { get :skater, params: { name: skater.name } }
      its(:body) { is_expected.to have_content(skater.name) }
    end

    context 'format: .json' do
      subject { get :skater, params: { name: skater.name, format: :json } }
      its(:body) { is_expected.to have_content(skater.name) }
    end
  end
end
