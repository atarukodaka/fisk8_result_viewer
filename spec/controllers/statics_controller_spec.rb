require 'rails_helper'

describe StaticsController, type: :controller do
  render_views

  describe '#index' do
    subject { create(:competition, :world); get :index }
    it { is_expected.to be_successful }
  end
end
