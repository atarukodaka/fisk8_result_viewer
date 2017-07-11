class ScoresController < ApplicationController
  def fetch_rows
    Score.includes(:competition, :skater).references(:competition, :skater).all
  end
  def columns
    [
     {name: "name", table: "competitions"},
     {name: "competition_name", table: "competitions", column_name: "name"},
     {name: "category", table: "scores"},
     :segment,
     {name: "season", table: "competitions"},
     :date, :result_pdf,
     :ranking,
     {name: "skater_name", table: "skaters", column_name: 'name'},
     {name: "nation", table: "skaters"},
     :tss, :tes, :pcs, :deductions, :base_value,
    ]
  end
  def order
    [[:date, :desc], [:category, :asc], [:segment, :desc], [:ranking, :asc]]
  end
  ################################################################
  def score_info(score)
    Listtable.new(score, [:skater_name, :competition_name, :category, :segment, :date, :tss, :tes, :pcs, :deductions, :result_pdf, :youtube_search])

  end
  def elements_datatable(score)
    Datatable.new(score.elements, [:number, :name, :element_type, :info, :base_value, :credit, :goe, :judges, :value])
  end

  def components_datatable(score)
    Datatable.new(score.components, [:number, :name, :factor, :judges, :value])
  end
  def show
    score = Score.find_by(name: params[:name]) ||
      raise(ActiveRecord::RecordNotFound.new("no such score name: '#{params[:name]}'"))

    respond_to do |format|
      format.html { render locals: {
          score_summary: score_summary(score),
          elements_datatable: elements_datatable(score),
          components_datatable: components_datatable(score)
        }
      }
      format.json {
        render json: score.as_json
          .merge({
                   elememnts: elements_datatable(score),
                   components: components_datatable(score)
                 })
      }
    end
  end
end
