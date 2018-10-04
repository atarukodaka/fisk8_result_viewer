namespace :update do
  desc 'update skaters'
  task :skaters => :environment do
    SkaterUpdater.new(verbose: true).update_skaters # (details: details)
  end

  desc 'update skater detail'
  task :skater_detail => :environment do
    isu_number = ENV['isu_number'] || raise('no isu_number given')
    SkaterUpdater.new(verbose: true).update_skater_detail(isu_number)
  end

  desc 'update all skaters detail'
  task :skaters_detail => :environment do
    SkaterUpdater.new(verbose: true).update_skaters _detail
  end
  ################
  desc 'update competitions listed in config/competitions.yml'
  task :competitions => :environment do
    ## options
    last = ENV['last'].to_i if ENV['last']
    force = ENV['force'].to_i.nonzero?

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
        CompetitionUpdater.new(parser_type: item[:parser_type], verbose: true, enable_judge_details: enable_judge_details)
          .update_competition(item[:site_url], date_format: item[:date_format], force: force, categories: categories, season_from: season_from, season_to: season_to, params: params).tap do |competition|
        end
      end
    end ## each
    DeviationsUpdater.new(verbose: true).update_deviations if enable_judge_details
  end ## task

  ################
  desc 'update deviation'
  task :deviations => :environment do
    DeviationsUpdater.new(verbose: true).update_deviations
  end
end # namespace
