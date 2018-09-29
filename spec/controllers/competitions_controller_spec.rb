require 'rails_helper'

RSpec.describe CompetitionsController, type: :controller do
  render_views
  
  let!(:main) {    create(:competition, :world)  }
  let!(:sub)   {    create(:competition, :finlandia) }
  ################
  ## index
  describe '#list' do
    context 'all' do
      subject { get :list, xhr: true ; response.body }
      it_behaves_like :both_main_sub
    end

    datatable = CompetitionsDatatable.new
    describe 'filters: ' do
      datatable.columns.select(&:searchable).map(&:name).each do |key|
        it key do; expect_filter(main, sub, key); end
      end
    end
    context 'sort: ' do
      datatable.columns.select(&:orderable).map(&:name).each do |key|
        it key do; expect_order(main, sub, key); end
      end
    end
    context 'format: ' do
      [[:json, 'application/json'], [:csv, 'text/csv']].each do |format, content_type|
        context ".#{format}" do
          subject { get :index, { format: format }; response.body }
          it_behaves_like :both_main_sub
        end
      end
    end
  end # list

  ################
  describe '#show' do
    let(:score){
      main.scores.first
    }
    context 'short_name' do
      subject { get :show, params: { short_name: main.short_name } }
      its(:body) { is_expected.to include(main.name) }
    end

    context 'short_name/category' do
      subject {
        get :show, params: { short_name: main.short_name, category: score.category.name }
      }
      its(:body) {
        is_expected.to include(main.name)
        is_expected.to include(score.category.name)
      }
    end
    context 'short_name/category/segment' do

      subject {
        get :show, params: { short_name: main.short_name, category: score.category.name, segment: score.segment.name}
      }
      its(:body) {
        is_expected.to include(main.name)
        is_expected.to include(score.category.name)
        is_expected.to include(score.segment.name)
        is_expected.to include(score.performed_segment.officials.first.panel.name)
      }
    end
    context 'redirection to score' do
      subject {
        get :show, params: { short_name: main.short_name, category: score.category.name, segment: score.segment.name, ranking: 1}
      }
      it {is_expected.to redirect_to score_path(score.name) }
    end
    context 'format: json' do
      subject {
        get :show, params: { short_name: main.short_name, category: score.category.name, segment: score.segment.name, format: "json" }
      }
      its(:content_type) { is_expected.to eq('application/json')}
      its(:body) { is_expected.to include(main.name) }
    end

  end
end
