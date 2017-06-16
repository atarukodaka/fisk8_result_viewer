require 'rails_helper'

RSpec.configure do |c|
  c.filter_run_excluding error_handler: true
end

RSpec.describe 'error handlers', error_handler: true do
  describe SkatersController, type: :controller do
    render_views

    describe 'skaters/:isu_number 404' do
      it {
        get :show, params: { isu_number: -1 }
        expect(response).to have_http_status(404)
      }
    end
  end

  describe CompetitionsController, type: :controller do
    render_views

    describe 'competitions/:short_name 404' do
      it {
        get :show, params: { short_name: "----------" }
        expect(response).to have_http_status(404)
      }
    end
  end

  describe ScoresController, type: :controller do
    render_views

    describe 'scores/:name 404' do
      it {
        get :show, params: { name: "----------" }
        expect(response).to have_http_status(404)
      }
    end
  end
end
