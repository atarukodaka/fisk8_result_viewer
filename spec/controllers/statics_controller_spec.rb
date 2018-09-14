require 'rails_helper'

describe StaticsController, type: :controller do
  render_views

  describe '#index' do
    subject { get :index }
    it { is_expected.to be_success }
  end
end
