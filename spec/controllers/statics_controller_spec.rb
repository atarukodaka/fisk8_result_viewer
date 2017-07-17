require 'rails_helper'

RSpec.describe SkatersController, type: :controller do
  render_views

  it do
    get :index
    expect_to_include('Statics')
  end
end
