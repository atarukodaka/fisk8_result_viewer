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

  describe '#show' do
    it {
      ## TODO: show spec
    }
  end
end
