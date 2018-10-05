require 'rails_helper'

RSpec.configure do |c|
  c.filter_run_excluding error_handler: true
end

RSpec.describe 'error handlers', error_handler: true do
  ## 500
  describe ApplicationController, type: :controller do
    controller do
      def index
        render status: :internal_server_error,
               json: { status: :internal_server_error, message: 'Internal Server Error' }
      end
    end

    it '500' do
      get :index
      expect(response).to have_http_status(500)
    end
  end

  ## 404
  describe SkatersController, type: :controller do
    it 'skaters/:isu_number 404' do
      get :show, params: { isu_number: -1 }
      expect(response).to have_http_status(404)
    end
  end

  describe CompetitionsController, type: :controller do
    it 'competitions/:short_name 404' do
      get :show, params: { short_name: '----------' }
      expect(response).to have_http_status(404)
    end
  end

  describe ScoresController, type: :controller do
    it 'scores/:name 404' do
      get :show, params: { name: '----------' }
      expect(response).to have_http_status(404)
    end
  end
end
