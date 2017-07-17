require 'rails_helper'

RSpec.describe StaticsController, type: :controller do
  render_views

  it do
    get :index
    expect_to_include('Statics')
  end
end
