namespace :update do
  desc "update skater"
  task :skaters  => :environment do
    details = ENV['details'].to_i.nonzero?
    
    SkaterUpdater.new(verbose: true).update_skaters(details: details)
  end

  ################
  desc "update competitions listed in config/competitions.yml"
  task :competitions => :environment do
    ## options
    last =  ENV['last'].to_i if ENV['last']
    force =  ENV['force'].to_i.nonzero?

    categories = 
      if (c = ENV['categories'])
        c.to_s.split(/\s*,\s*/).map do |cat|
          Category.where(name: cat).first
        end.compact
      else
        Category.all
      end
    if (f = ENV['filename'])
      CompetitionList.filename = f
    end
    season_from = ENV['season_from']
    season_to = ENV['season_to']
    enable_judge_details = ENV['enable_judge_details'].to_i.nonzero?

    ################
    list = CompetitionList.all
    list = list.last(last).reverse if last

    list.each do |item|
      ActiveRecord::Base.transaction do
        params = {
          city: item[:city], name: item[:name], comment: item[:comment]
        }
        CompetitionUpdater.new(parser_type: item[:parser_type], verbose: true, enable_judge_details: enable_judge_details).
          update_competition(item[:site_url], date_format: item[:date_format], force: force, categories: categories, season_from: season_from, season_to: season_to, params: params).tap do |competition|
        end
      end
    end  ## each
  end ## task

  ################
  desc 'update deviation'
  task :deviations => :environment do
    data = {}
    ElementJudgeDetail.where("officials.absence": false).joins(:element, :official).group("elements.score_id").group(:official_id).sum(:abs_deviation).each do |key, value|
      data[key] ||= {}
      data[key][:tes] = value
    end
    ComponentJudgeDetail.where("officials.absence": false).joins(:component, :official).group("components.score_id").group(:official_id).sum(:deviation).each do |key, value|
      data[key] ||= {}
      data[key][:pcs] = value
    end
    scores = Score.all.index_by(&:id)  ## TODO: use memory too much ??
    
    ActiveRecord::Base.transaction do
      puts "start"
      Deviation.delete_all    ## clear all data first
      data.each do |(score_id, official_id), hash|
        Deviation.create(
          score_id: score_id, official_id: official_id,
          tes_deviation: hash[:tes],
          pcs_deviation: hash[:pcs],
          tes_deviation_ratio: hash[:tes] / scores[score_id].elements.count,
          pcs_deviation_ratio: hash[:pcs].abs / 7.5,
        )
      end
      ## delete invalid panel's data
      #puts "delete invaid panel's data"
      #Deviation.where("panels.name": "-").joins(official: [ :panel]).map(&:delete)
    end  ## transaction
  end
end  # namespace
