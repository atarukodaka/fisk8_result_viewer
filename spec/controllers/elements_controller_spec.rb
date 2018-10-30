require 'rails_helper'
require_relative 'concerns/index_controller_spec_helper'

RSpec.describe ElementsController, type: :controller do
  render_views

  let!(:world_score) { create(:competition, :world).scores.first }
  let!(:finlandia_score)  { create(:competition, :finlandia).scores.first }

  let(:solo_jump) { world_score.elements.where(element_type: 'jump', element_subtype: 'solo').first }
  let(:combination_jump) { world_score.elements.where(element_type: 'jump', element_subtype: 'comb').first }
  let(:layback_spin) { finlandia_score.elements.where(element_type: 'spin').first }

  describe '#index' do
    datatable = ElementsDatatable.new
    include_context :contains_all, datatable
    [:json, :csv].each do |format|
      include_context :format_response, datatable, format: format
    end
  end
end
