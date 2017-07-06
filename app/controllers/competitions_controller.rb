class CompetitionsController < ApplicationController
  include ApplicationHelper
  include Contracts
  using SortWithPreset
  
  Contract None => Hash
  def filters
    {
      name: ->(col, v) { col.name_matches(v) },
      site_url: ->(col, v) { col.site_url_matches(v) },
      competition_type: ->(col, v) { col.where(competition_type: v) },
      #isu_championships_only: ->(col, v) { col.where(isu_championships: v.to_bool) },
=begin
      isu_championships: ->(col, v){
        (v.to_bool) ? col.where(isu_championships: v.to_bool) : col
      },
=end
      season: ->(col, v) { col.where(season: v) },
    }
  end
  Contract None => ActiveRecord::Relation
  def create_collection
    Competition.all
  end
  def create_datatable
    #super.add_option(:default_order, [:start_date, :desc])
    super.tap {|t|
      t.order = {start_date: :desc}
    }
  end
  
  def columns
    [:short_name, :name, :site_url, :city, :country, :competition_type,
     :season, {name: :start_date, order: :desc}, :end_date,
    ]
  end

  ################################################################
  def show
    competition = Competition.find_by(short_name: params[:short_name]) || raise(ActiveRecord::RecordNotFound)

    category = params[:category]
    segment = params[:segment]

    category_segments = competition.scores.order(:date).select(:category, :segment).map {|d| d.attributes}.uniq.group_by {|d| d["category"]}.map {|k, ary|
      [k, ary.map {|d| d["segment"]}]
    }.to_h
    categories = category_segments.keys.sort_with_preset(["MEN", "LADIES", "PAIRS", "ICE DANCE"])
      
    result_type, result_datatable = 
      if category.blank? and segment.blank?
        [nil, nil]
      elsif segment.blank?
        [:category, Datatable.new(competition.category_results.category(category).includes(:skater, :scores), [:ranking, :skater_name, :nation, :points, :short_ranking, :short_tss, :free_ranking, :free_tss])]
      else
        [:segment, Datatable.new(competition.scores.segment(category, segment).order(:ranking).includes(:skater, :elements, :components), [:ranking, :skater_name, :nation, :starting_number, :tss, :tes, :pcs, :deductions, :elements_summary, :components_summary])]
      end
    
    respond_to do |format|
      locals = {
        competition: competition,
        category: category,
        segment: segment,
        categories: categories,
        category_segments: category_segments,
        result_type: result_type,
        result_datatable: result_datatable,
        #category_results: (Datatable.new(competition.category_results.category(category).includes(:skater, :scores), [:ranking, :skater_name, :nation, :points, :short_ranking, :short_tss, :free_ranking, :free_tss]) if category && segment.blank?),
        #segment_scores: (Datatable.new(competition.scores.segment(category, segment).order(:ranking).includes(:skater, :elements, :components), [:ranking, :skater_name, :nation, :starting_number, :tss, :tes, :pcs, :deductions, :elements_summary, :components_summary]) if segment),
      }

      format.html {
        render :show, locals: locals
      }
      format.json {
        render json: competition.as_json.merge({results: result_datatable})
      }
    end
  end
end
