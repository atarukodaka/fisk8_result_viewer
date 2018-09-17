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
=begin
    if (categories = ENV['accept_categories'])
      Category.accept!(categories.split(/,/))
    end
=end
    #categories = (c = ENV['categories']) ? c.to_s.split(/ *, */) : nil
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

    ################
    list = CompetitionList.all
    list = list.last(last).reverse if last

    list.each do |item|
      ActiveRecord::Base.transaction do
        params = {
          city: item[:city], name: item[:name], comment: item[:comment]
        }
        CompetitionUpdater.new(parser_type: item[:parser_type], verbose: true).
          update_competition(item[:site_url], date_format: item[:date_format], force: force, categories: categories, params: params).tap do |competition|
        end
      end
    end  ## each
  end
end  # namespace
