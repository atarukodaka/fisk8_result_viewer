require 'rails_helper'
require_relative 'concerns/index_controller_spec_helper'

RSpec.describe ScoresController, type: :controller do
  render_views

  let!(:main) { create(:competition, :world).scores.first }
  let!(:sub)  { create(:competition, :finlandia).scores.first }

  ################
  describe '#index' do
    datatable = ScoresDatatable.new
    include_context :contains_all, datatable
    [:json, :csv].each do |format|
      include_context :format_response, datatable, format: format
    end
  end

  describe '#show ' do
    context 'name', vcr: true do
      subject { get :show, params: { name: main.name } }
      its(:body) { is_expected.to include(main.name) }
    end

    context 'format: .json', vcr: true do
      subject { get :show, params: { name: main.name, format: :json } }
      its(:body) { is_expected.to have_content(main.name) }
    end

=begin
    context 'format: .xml' do
      subject { get :show, params: { name: main.name, format: :xml } }
      its(:body) { is_expected.to have_content(main.name) }
    end
=end
  end
end
