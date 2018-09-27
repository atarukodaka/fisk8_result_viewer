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
    subject { get :index }
    it { is_expected.to be_success}
  end
  describe '#list' do
    describe 'all' do
      subject { get :list, xhr: true }
      its(:body) { is_expected.to include(first.score.name) }
      its(:body) { is_expected.to include(second.score.name) }
    end

=begin
    datatable = DeviationsDatatable.new
    describe 'filter: ' do
      datatable.columns.select(&:searchable).map(&:score_name).each do |key|
        it key do
          expect_filter(first, second, key)
        end
      end
    end
    describe 'sort: ' do
      datatable.columns.select(&:orderable).map(&:score_name).each do |key|
        it key do
          expect_order(first, second, key)
        end
      end
    end
=end
  end
end


