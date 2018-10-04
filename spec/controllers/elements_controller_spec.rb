require 'rails_helper'

RSpec.describe ElementsController, type: :controller do
  render_views

  let(:solo_jump) { Element.where(element_type: 'jump', element_subtype: 'solo').first }
  let(:combination_jump) { Element.where(element_type: 'jump', element_subtype: 'comb').first }
  let(:layback_spin) { Element.where(element_type: 'spin').first }

  describe '#index' do
    before(:all) {
      create(:competition, :world)
      create(:competition, :finlandia)
    }

    describe 'all' do
      subject { get :index }
      it { is_expected.to be_success }
      its(:body) { is_expected.to have_content(solo_jump.name) }
      its(:body) { is_expected.to have_content(combination_jump.name) }
      its(:body) { is_expected.to have_content(layback_spin.name) }
    end
  end
end
