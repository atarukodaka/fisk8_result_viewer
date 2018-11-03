class GrandprixesController < ApplicationController
  using StringToModel
  include DebugPrint

  def index
    category = params[:category].to_s.to_category
    seasons = GrandprixEvent.order(season: :desc).pluck(:season).uniq
    season = params[:season] || seasons.first || ''

    events = GrandprixEvent.where(season: season, category: category)
             .includes(:grandprix_entries, grandprix_entries: [:skater])

    simulation_parameters = {
      times:  (params[:simulation_times] || 100).to_i,
      stddev_ratio: (params[:stddev_ratio] || 0.2).to_f,
    }

    results = GrandprixSimulator.new.run(events, parameters: simulation_parameters)

    render :index, locals: { season: season, seasons: seasons,
                             category: category, events: events,
                             results: results, simulation_parameters: simulation_parameters }
  end
end
