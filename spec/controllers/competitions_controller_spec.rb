require 'rails_helper'
require 'controller_spec_helper'

RSpec.describe CompetitionsController, type: :controller do
  render_views
  
  let!(:world)       { create(:competition, :world)     }
  let!(:finlandia)   { create(:competition, :finlandia) }

  ################
  describe '#index' do
    datatable = CompetitionsDatatable.new
    include_context :contains_all, datatable
    [:json, :csv].each do |format|
      include_context :format_response, datatable, format: format
    end
  end

  ################
  describe '#show' do
    let(:score) { world.scores.first }
    let(:category) { score.category }
    let(:segment) { score.segment }

    context 'short_name' do
      subject { get :show, params: { short_name: world.short_name } }
      its(:body) { is_expected.to have_content(world.name) }
    end

    context 'short_name/category' do
      subject {
        get :show, params: { short_name: world.short_name, category: category.name }
      }
      its(:body) {
        is_expected.to have_content(world.name)
        is_expected.to have_content(category.name)
      }
    end
    context 'short_name/category/segment' do
      subject {
        get :show, params: { short_name: world.short_name,
                             category: score.category.name, segment: score.segment.name }
      }
      its(:body) {
        is_expected.to have_content(world.name)
        is_expected.to have_content(category.name)
        is_expected.to have_content(segment.name)
        is_expected.to have_content(score.performed_segment.officials.first.panel.name)
      }
    end
    context 'format: json' do
      subject {
        get :show, params: { short_name: world.short_name,
                             category: score.category.name, segment: score.segment.name, format: 'json' }
      }
      its(:content_type) { is_expected.to eq('application/json') }
      its(:body) { is_expected.to have_content(world.name) }
    end
  end
end
