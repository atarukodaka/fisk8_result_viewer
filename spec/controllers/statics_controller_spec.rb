require 'rails_helper'

RSpec.describe StaticsController, type: :controller do
  render_views

  context do
    subject { get :index }
    its(:body) { is_expected.to include('Statics') }
  end
end
