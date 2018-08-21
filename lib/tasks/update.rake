namespace :update do
  desc "update skater"
  task :skaters  => :environment do
    #Category.update_skaters
    SkaterUpdater.new.update_skaters
  end

  ################
=begin
  desc "update compeitition with specific url"
  task :competition => :environment do
    url = ENV['url']
    ## TODO: parser_type, comment
    
    if (categories = ENV['accept_categories'])
      Category.accept!(categories.split(/,/))
    end

    Competition.where(site_url: url).map(&:destroy)
    Competition.create(site_url: url) do |competition|
      competition.update(verbose: true)
    end
  end
=end
  ################
  desc "update competitions listed in config/competitions.yml"
  task :competitions => :environment do
    ## options
    last =  ENV['last'].to_i if ENV['last']
    force =  ENV['force'].to_i.nonzero?

    if (categories = ENV['accept_categories'])
      Category.accept!(categories.split(/,/))
    end

    if (f = ENV['filename'])
      CompetitionList.filename = f
    end

    ################
    list = CompetitionList.all
    list = list.last(last).reverse if last

    list.each do |item|
=begin
      if competitions = Competition.where(site_url: item[:site_url]).presence
        if force
          competitions.map(&:destroy)
        else
          puts "skip: #{item[:site_url]}"
          next
        end
      end
=end
      ActiveRecord::Base.transaction do
        params = {
          city: item[:city], name: item[:name], comment: item[:comment]
        }
        CompetitionUpdater.new(parser_type: item[:parser_type], verbose: true).
          update_competition(item[:site_url], date_format: item[:date_format], force: force, params: params).tap do |competition|
        end
      end
    end  ## each
  end
end  # namespace
