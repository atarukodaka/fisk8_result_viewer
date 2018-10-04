require 'rails_helper'

RSpec.describe ScoresController, type: :controller do
  render_views

  let!(:main) { create(:competition, :world).scores.first     }
  let!(:sub)  { create(:competition, :finlandia).scores.first  }

  ################
  describe '#index' do
    subject { get :index }
    it { is_expected.to be_success }
  end

  describe '#show ' do
    context 'name' do
      subject { get :show, params: { name: main.name } }
      its(:body) { is_expected.to include(main.name) }
    end

    context 'format: .json' do
      subject { get :show, params: { name: main.name, format: :json } }
      its(:body) { is_expected.to include(main.name) }
    end
  end
end
