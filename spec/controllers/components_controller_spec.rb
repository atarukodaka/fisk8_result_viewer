require 'rails_helper'

RSpec.describe ComponentsController, type: :controller do
  render_views

  let!(:score_world)  {
    competition = create(:competition, :world)
    competition.scores.first
  }
  let!(:score_finlandia)  {
    competition = create(:competition, :finlandia)
    competition.scores.first
  }

  let!(:short_ss){
    create(:competition, :world).scores.first.components.create(number: 1, name: 'Skating Skill', factor: 1.0, value: 10.0, judges: '10 10 10')
  }
  let!(:free_tr){
    create(:competition, :finlandia).scores.first.components.create(number: 2, name: 'Transitions', factor: 1.8, value: 9.0, judges: '9 9 9')
  }

  ################
  describe '#index' do
    describe 'all' do
      subject { get :index }
      it { is_expected.to be_success }
    end
  end

  describe '#list' do
    describe 'all' do
      subject { get :list, xhr: true }
      its(:body) { is_expected.to include(short_ss.name) }
    end

    datatable = ComponentsDatatable.new
    describe 'filter: ' do
      datatable.columns.select(&:searchable).map(&:name).each do |key|
        next if key.to_sym == :value  # TODO
        it key do
          expect_filter(short_ss, free_tr, key)
        end
      end
    end

    describe 'sort:' do
      datatable.columns.select(&:orderable).map(&:name).each do |key|
        it key do
          expect_order(short_ss, free_tr, key)
        end
      end
    end

    describe 'value comparison' do
      shared_examples :short_ss_only do
        its(:body) { is_expected.to include(short_ss.name) }
        its(:body) { is_expected.not_to include(free_tr.name) }
      end
      shared_examples :free_tr_only do
        its(:body) { is_expected.not_to include(short_ss.name) }
        its(:body) { is_expected.to include(free_tr.name) }
      end

      context 'compares by >' do
        subject { get :list, xhr: true, params: { value: '9.5', value_operator: 'gt' } }
        it_behaves_like :short_ss_only
      end
      context 'compares by <' do
        subject { get :list, xhr: true, params: { value: '9.5', value_operator: 'lt' } }
        it_behaves_like :free_tr_only
      end
      context 'compares by <=' do
        subject { get :list, xhr: true, params: { value: '9', value_operator: 'lteq' } }
        it_behaves_like :free_tr_only
      end
      context 'compares by >=' do
        subject { get :list, xhr: true, params: { value: '10', value_operator: 'gteq' } }
        it_behaves_like :short_ss_only
      end
      context 'compares by =' do
        subject { get :list, xhr: true, params: { value: '9', value_operator: 'eq' } }
        it_behaves_like :free_tr_only
      end
    end
  end
end
