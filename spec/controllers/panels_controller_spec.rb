require 'rails_helper'
require_relative 'concerns/index_controller_spec_helper'

describe PanelsController, type: :controller do
  render_views

  let!(:world) { create(:competition, :world) }
  let!(:john) {    world.performed_segments.first.officials.first.panel }
  let!(:mike) {    world.performed_segments.first.officials.second.panel }

  describe '#index' do
    datatable = PanelsDatatable.new
    include_context :contains_all, datatable
    [:json, :csv].each do |format|
      include_context :format_response, datatable, format: format
    end
  end
  ################
  describe '#show' do
    context 'name' do
      subject { get :show, params: { name: john.name } }
      its(:body) { is_expected.to have_content(john.name) }
    end

    context 'format: .json' do
      subject { get :show, params: { name: john.name, format: :json } }
      its(:body) { is_expected.to have_content(john.name) }
    end
  end
end
