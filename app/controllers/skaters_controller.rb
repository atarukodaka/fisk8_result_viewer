class SkatersController < ApplicationController
  def order
    [[:category, :asc]]
  end
  def columns
    [:name, :category]
  end
  def filter_arel(cols)
    arel = nil
    cols.map do |column|
      sv = params[column[:name]] || next
      model = (column[:table].try(:classify) || controller_name.classify).constantize
      this_arel = model.arel_table[column.column_name].matches("%#{sv}%")
      arel = (arel) ? arel.and(this_arel) : this_arel
    end
    arel    
  end
  def index
    respond_to do |format|
      format.html {
        cols = Columns.new(columns)
        table = Datatable.new(columns: cols, settings: {ajax: url_for(action: :list, format: :json, params: params.permit(cols.names)), serverSide: true})
        if order.present?
          table.settings[:order] = order.map {|pair|
            [table.column_names.index(pair[0].to_s), pair[1]]
          }
        end
        render :index, locals: {table: table }
      }
      format.json {
        cols = Columns.new(columns)
        rows = Skaters.limit(100).where(filter_arel)
        table = Datatable.new(columns: cols, rows: rows)
        # filter
        
        render json: table
      }
      
    end
  end
  def list
    cols = Columns.new(columns)
    rows = Skater.all.where(filter_arel(cols))
    table = ServersideDatatable.new(columns: columns, rows: rows, params: params)
    render json: table
  end

  
  ################################################################
  def show
    skater = Skater.find_by(isu_number: params[:isu_number]) ||
      Skater.find_by(name: params[:isu_number]) || 
      raise(ActiveRecord::RecordNotFound.new("no such skater"))

    cr = skater.category_results
    record_summary_hash = {
      highest_score: cr.maximum(:points),
      number_of_competitions_participated: cr.count,
      number_of_gold_won: cr.where(ranking: 1).count,
      most_valuable_element: skater.elements.order(:value).last.decorate.description,
      most_valuable_components: skater.components.group(:number).maximum(:value).values.join('/'),
    }
    
    ## tables
    tables = {
      skater_info_table: Listtable.new(skater.decorate, [:name, :nation, :isu_number, :category]),
      record_summary_table: Listtable.new(Hashie::Mash.new(record_summary_hash)),
      competition_results_table: SkaterResultsDatatable.new(skater: skater),
      #competition_results_table: DomDatatable.new(skater.category_results.recent.includes(:competition, :scores), [:competition_name, :date, :category, :ranking, :points, :short_ranking, :short_tss, :short_tes, :short_pcs, :short_deductions, :free_ranking, :free_tss, :free_tes, :free_pcs, :free_deductions,]),
    }
    ## score graph
    score_graphs = skater.scores.order(:date).group_by {|s| s.segment}.map do |segment, scores|
      ScoreGraph.new(skater, segment, scores).tap {|sg|
        sg.plot
      }
    end
    
    ## render
    respond_to do |format|
      format.html {
        render action: :show, locals: { skater: skater, score_graphs: score_graphs}.merge(tables)
      }
      format.json {
        render json: {
          skater_info: tables[:skater_info_table],
          record_summary_table: tables[:record_summary_table],
          competition_results: tables[:competition_results_table],
        }
      }
    end
  end
end
