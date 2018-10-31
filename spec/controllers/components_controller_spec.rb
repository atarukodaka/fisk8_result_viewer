require 'rails_helper'
require_relative 'concerns/index_controller_spec_helper'

RSpec.describe ComponentsController, type: :controller do
  render_views

  let!(:world_score) { create(:competition, :world).scores.first }
  let!(:finlandia_score)  { create(:competition, :finlandia).scores.first }

  let(:short_ss) { world_score.components.where(name: 'Skating Skills').first }
  let(:free_tr) { finlandia_score.components.where(name: 'Transitions').first }
  ################
  describe '#index' do
    datatable = ComponentsDatatable.new
    include_context :contains_all, datatable
    [:json, :csv].each do |format|
      include_context :format_response, datatable, format: format
    end
  end
end
