class GrandprixesController < ApplicationController
  using StringToModel
  include DebugPrint

  def index
    season = SkateSeason.new(params[:season] || '2018-19')
    category = (params[:category_name] || 'MEN').to_category

    events = GrandprixEvent.where(season: season.to_s, category: category)
             .includes(:grandprix_entries, grandprix_entries: [:skater])

    simulation_parameters = {
      times:  (params[:simulation_times] || 100).to_i,
      stddev_ratio: (params[:stddev_ratio] || 0.2).to_f,
    }

    results = GrandprixSimulator.new.run(events, parameters: simulation_parameters)

    render :index, locals: { season: season, category: category, events: events,
                             results: results, simulation_parameters: simulation_parameters }
  end
end