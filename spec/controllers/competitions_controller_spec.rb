require 'rails_helper'

RSpec.describe CompetitionsController, type: :controller do
  render_views

  let!(:world)       { create(:competition, :world)     }
  let!(:finlandia)   { create(:competition, :finlandia) }

  ################
  ## examples
  shared_examples :having_all do
      its(:body) { is_expected.to have_content(world.name) }
      its(:body) { is_expected.to have_content(finlandia.name) }
  end

  ################
  ## index
  describe '#index' do
    context 'all' do
      subject { get :index  }
      it_behaves_like :having_all
    end
    
    context 'format: ' do
      [[:json, 'application/json'], [:csv, 'text/csv']].each do |format, content_type|
        context ".#{format}" do
          subject { get :index, { format: format } }
          it_behaves_like :having_all
        end
      end
    end
  end 

  ################
  describe '#show' do
    let(:score){
      world.scores.first
    }
    context 'short_name' do
      subject { get :show, params: { short_name: world.short_name } }
      its(:body) { is_expected.to have_content(world.name) }
    end

    context 'short_name/category' do
      subject {
        get :show, params: { short_name: world.short_name, category: score.category.name }
      }
      its(:body) {
        is_expected.to have_content(world.name)
        is_expected.to have_content(score.category.name)
      }
    end
    context 'short_name/category/segment' do

      subject {
        get :show, params: { short_name: world.short_name, category: score.category.name, segment: score.segment.name }
      }
      its(:body) {
        is_expected.to have_content(world.name)
        is_expected.to have_content(score.category.name)
        is_expected.to have_content(score.segment.name)
        is_expected.to have_content(score.performed_segment.officials.first.panel.name)
      }
    end
    context 'redirection to score' do
      subject {
        get :show, params: { short_name: world.short_name, category: score.category.name, segment: score.segment.name, ranking: 1 }
      }
      it {is_expected.to redirect_to score_path(score.name) }
    end
    context 'format: json' do
      subject {
        get :show, params: { short_name: world.short_name, category: score.category.name, segment: score.segment.name, format: 'json' }
      }
      its(:content_type) { is_expected.to eq('application/json')}
      its(:body) { is_expected.to have_content(world.name) }
    end

  end
end
