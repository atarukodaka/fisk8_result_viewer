require 'rails_helper'

RSpec.describe CompetitionsController, type: :controller do
  render_views
  
  let!(:world) {
    skater = create(:skater)
    competition = create(:competition)
    cr = competition.results.create(skater: skater, category: "MEN", ranking: 1)
    score = competition.scores.create(skater: skater, category: "MEN", segment: "SHORT", ranking: 1, result: cr)
    competition
  }
  let!(:score){
    world.scores.first
  }
  let!(:finlandia){
    create(:competition, :finlandia)
  }
  ################################################################
  shared_examples :having_all do
    its(:body) { is_expected.to include(world.name) }
    its(:body) { is_expected.to include(finlandia.name)}
  end

  describe '#list' do
    context 'all' do
      subject { get :list, xhr: true }
      it_behaves_like :having_all
    end

    datatable = CompetitionsDatatable.new
    describe 'filters: ' do
      datatable.columns.select(&:searchable).map(&:name).each do |key|
        it key do; expect_filter(world, finlandia, key); end
      end
    end
    context 'sort: ' do
      datatable.column_names.each do |key|
        it key do; expect_order(world, finlandia, key); end
      end
    end
    describe 'format: ' do
      [[:json, 'application/json'], [:csv, 'text/csv']].each do |format, content_type|
        context ".#{format}" do
          subject { get :index, { format: format } }
          its(:content_type) { is_expected.to eq(content_type) }
          it_behaves_like :having_all
        end
      end
    end
  end

  ################
  describe '#show' do
    context 'short_name' do
      subject { get :show, params: { short_name: world.short_name } }
      its(:body) { is_expected.to include(world.name) }
    end

    context 'short_name/category' do
      subject {
        get :show, params: { short_name: world.short_name, category: score.category }
      }
      its(:body) {
        is_expected.to include(world.name)
        is_expected.to include(score.category)
      }
    end
    context 'short_name/category/segment' do
      subject {
        get :show, params: { short_name: world.short_name, category: score.category, segment: score.segment}
      }
      its(:body) {
        is_expected.to include(world.name)
        is_expected.to include(score.category)
        is_expected.to include(score.segment)        
      }
    end
    context 'format: json' do
      subject {
        get :show, params: { short_name: world.short_name, category: score.category, segment: score.segment, format: "json" }
      }
      its(:content_type) { is_expected.to eq('application/json')}
      its(:body) { is_expected.to include(world.name) }
    end

  end
end
