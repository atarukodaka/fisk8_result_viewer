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

    Competition.where(site_url: url).map(&:destory)
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
      Competition.create! do |competition|
        competition.attributes = {
          site_url: item[:site_url],
          parser_type: item[:parser_type],
          comment: item[:comment],
        }
        competition.update(verbose: true)
        competition.city = item[:city] if item[:city]
      end
    end
  end
end  # namespace
