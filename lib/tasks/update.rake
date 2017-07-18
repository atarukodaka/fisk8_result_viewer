namespace :update do
  desc "update skater"
  task :skaters  => :environment do
    Category.update_skaters
  end

  desc "update competitions listed in config/competitions.yml"
  task :competitions => :environment do
    last =  ENV['last'].to_i if ENV['last']
    force =  ENV['force'].to_i.nonzero?

    if categories = ENV['accept_categories']
      Category.accept!(categories.split(/,/))
    end

    ## TODO: full_path??
    if f = ENV['filenames']
      CompetitionList.use_multiple_files
      CompetitionList.set_filenames *(f.split(/,/))
    elsif f = ENV['filename']
      CompetitionList.filename = f
    end
    list = CompetitionList.all
    list = list.last(last).reverse if last
      
    list.each do |item|
      if competitions = Competition.where(site_url: item[:url]).presence
        if !force
          puts "skip: #{item[:url]}"
          next
        else
          competitions.map(&:destroy)
        end
      end
      Competition.create!(site_url: item[:url], parser_type: item[:parser_type]) do |competition|
        competition.comment = item[:comment]
        competition.update(verbose: true)
      end
    end
  end
end  # namespace
