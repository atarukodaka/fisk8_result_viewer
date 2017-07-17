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
  context 'index: ' do
    it 'pure index request' do
      get :index
      expect(response).to be_success
      expect(response.body).to include("\"serverSide\":true")
    end

    it 'list' do
      get :list, xhr: true
      expect_to_include(world.name)
      expect_to_include(finlandia.name)
    end

    attrs = [:name, :site_url, :competition_type, :competition_class, :season]
    context 'filters:' do
      attrs.each do |key|
        it key do
          expect_filter(world, finlandia, key)

        end
      end
    end
    context 'sort: ' do
      "#{controller_class.to_s.sub(/Controller/, '')}Datatable".constantize.new
        .column_names.each do |key|
        it key do
          expect_order(world, finlandia, key)
        end
      end
    end
  
    context 'format: ' do
      {json: 'application/json', csv: 'text/csv'}.each do |format, content_type|
        it format do
          get :index, params: {format: format}
          expect(response.content_type).to eq(content_type)
          expect_to_include(world.name)
          expect_to_include(finlandia.name)
        end
      end
    end
  end
  ################
  context 'show: ' do
    it 'short_name' do
      get :show, params: { short_name: world.short_name }
      expect_to_include(world.name)
    end

    it 'short_name/category' do
      get :show, params: { short_name: world.short_name, category: score.category }
      expect_to_include(world.name)
      expect_to_include(score.category)
    end
    
    it 'short_name/category/segment' do
      get :show, params: { short_name: world.short_name, category: score.category, segment: score.segment}
      expect_to_include(world.name)
      expect_to_include(score.segment)
    end
    
    it 'json' do
      get :show, params: { short_name: world.short_name, category: score.category, segment: score.segment, format: "json" }
      expect(response.content_type).to eq("application/json")
      expect_to_include(world.name)
    end
  end
  ################
end
