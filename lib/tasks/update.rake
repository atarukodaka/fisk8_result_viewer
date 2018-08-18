namespace :update do
  desc "update skater"
  task :skaters  => :environment do
    Category.update_skaters
  end

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

  desc "update competitions listed in config/competitions.yml"
  task :competitions => :environment do
    last =  ENV['last'].to_i if ENV['last']
    force =  ENV['force'].to_i.nonzero?

    if (categories = ENV['accept_categories'])
      Category.accept!(categories.split(/,/))
    end

    ## filename
    if (f = ENV['filenames'])
      CompetitionList.use_multiple_files
      CompetitionList.set_filenames *(f.split(/,/)) ## TODO
    elsif (f = ENV['filename'])
      CompetitionList.filename = f
    end
    list = CompetitionList.all
    list = list.last(last).reverse if last
      
    list.each do |item|
      if competitions = Competition.where(site_url: item[:site_url]).presence
        if !force
          puts "skip: #{item[:site_url]}"
          next
        else
          competitions.map(&:destroy)
        end
      end
      updater = Updater.new(item[:parser_type], verbose: true)
      competition = updater.update_competition(site_url: item[:site_url], date_format: item[:date_format])

      ## override attributes
      ActiveRecord::Base.transaction do
        [:city, :name, :comment].each do |tag|
          competition[tag] = item[tag] if item[tag]
        end
        competition.save!
      end
=begin
      Competition.create! do |competition|
        updator.update_competition(competition, site_url: item[:site_url])
        attrs = [:site_url, :parser_type, :comment, :date_format]
        competition.attributes = item.attributes.slice(*attrs)
        params = {}
        [:city, :name].each do |tag|
          params[tag] = item[tag] if item[tag]
        end

        #competition.update(verbose: true, params: params)
        #competition.attributes = item.attributes
        #competition.update(params: params, verbose: true)
      end
=end
    end
  end
end  # namespace
