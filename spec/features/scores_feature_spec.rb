require 'rails_helper'

RSpec.configure do |c|
  c.filter_run_excluding feature: true
end

feature ScoresController, type: :feature, feature: true do
  let!(:main) { create(:competition, :world).scores.first }
  let!(:sub) { create(:competition, :finlandia).scores.first }
  let(:index_path) { scores_path }

  ################
  feature "#index", js: true do
    context 'all' do
      subject { visit index_path; page }
      it_behaves_like :both_main_sub
    end
    context 'filter' do
      [{ name: :skater_name, input_type: :fill_in, },
       {name: :competition_name, input_type: :fill_in,},
       {name: :competition_class, input_type: :select,},
       {name: :competition_type, input_type: :select,},
       {name: :category_name, input_type: :select, value_function: lambda {|score| score.category_name }},
       {name: :category_type, input_type: :select, },
       {name: :seniority, input_type: :select, },
       {name: :team, input_type: :select, },
       {name: :segment_name, input_type: :select, value_function: lambda {|score| score.segment_name }},
       {name: :segment_type, input_type: :select, },    
      ].each do |hash|
        include_context :ajax_filter, hash[:name], hash[:input_type], hash[:value_function]
      end
      
      include_context :filter_season
    end
    context 'order' do
      ScoresDatatable.new.columns.select(&:orderable).map(&:name).each do |key|
        include_context :ajax_order, key
      end
    end
  end
end
