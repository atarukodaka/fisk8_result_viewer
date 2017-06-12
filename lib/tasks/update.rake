namespace :update do
  desc "update skater"
  task :skaters  => :environment do
    include Fisk8ResultViewer::Utils
    accept_categories = str2symbols(ENV['accept_categories']) if ENV['accept_categories']
    updater = Fisk8ResultViewer::Skater::Updater.new
    updater.update_skaters(categories: accept_categories)
  end

  desc "update competitions listed in config/competitions.yml"
  task :competitions => :environment do
    include Fisk8ResultViewer::Utils
    options = {
      last: ENV['last'].to_i,
      force: ENV['force'].to_i.nonzero?,
      include_type: {
        challenger: ENV['include_challenger'].to_i.nonzero?,
        junior: ENV['include_junior'].to_i.nonzero?,
      }
    }
    accept_categories = str2symbols(ENV['accept_categories']) if ENV['accept_categories']
    
    updater = Fisk8ResultViewer::Competition::Updater.new
    items = updater.load_competition_list
    [:challenger, :junior].each do |type|
      items += updater.load_competition_list(type: type) if options[:include_type][type]
    end
    items = items.last(options[:last]).reverse if options[:last] > 0
    items.each do |item|
      Competition.where(site_url: item[:url]).map(&:destroy) if options[:force]
      updater.update_competition(item[:url], parser_type: item[:parser_type], comment: item[:comment], accept_categories: accept_categories)
    end
  end

  desc "update competition of given url"
  task :competition => :environment do
    url = ENV['url']
    force = ENV['force'].to_i.nonzero?
    comment = ENV['comment']
    parser_type = (t = ENV['parser_type']) ? t.to_sym :  :isu_generic
    Competition.where(site_url: url).map(&:destroy) if force
    updater = Fisk8ResultViewer::Competition::Updater.new
    updater.update_competition(url, parser_type: parser_type, comment: comment)
  end

  ################################################################
end  # namespace
