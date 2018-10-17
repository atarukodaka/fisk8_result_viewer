require 'rails_helper'

RSpec.describe ComponentsController, type: :controller do
  render_views

  let!(:world_score) { create(:competition, :world).scores.first }
  let!(:finlandia_score)  { create(:competition, :finlandia).scores.first }

  let(:short_ss) { world_score.components.where(name: 'Skating Skills').first }
  let(:free_tr) { finlandia_score.components.where(name: 'Transitions').first }
  ################
  describe '#index' do
    describe 'all' do
      subject { get :index }
      it { is_expected.to be_success }
      its(:body) { is_expected.to have_content(short_ss.name) }
      its(:body) { is_expected.to have_content(free_tr.name) }
    end
  end
end
