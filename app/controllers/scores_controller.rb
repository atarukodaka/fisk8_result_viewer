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
  def show
    score = Score.find_by(name: params[:name]) ||
      raise(ActiveRecord::RecordNotFound.new("no such score name: '#{params[:name]}'"))

    elements_datatable = Datatable.new(score.elements, [:number, :name, :element_type, :info, :base_value, :credit, :goe, :judges, :value])
    components_datatable = Datatable.new(score.components, [:number, :name, :factor, :judges, :value])

    respond_to do |format|
      format.html { render locals: {score: score, elements_datatable: elements_datatable, components_datatable: components_datatable}}
      format.json { render json: score.as_json.merge({elememnts: elements_datatable, components: components_datatable })}
    end
  end
end
