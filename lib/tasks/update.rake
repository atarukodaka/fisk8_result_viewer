namespace :update do
  desc "update skater"
  task :skaters  => :environment do
    categories = [:MEN]
    updater = Fisk8ResultViewer::Skater::Updater.new
    updater.update_skaters(categories: [:MEN])
  end

  task :competitions => :environment do
    options = {
      last: ENV['last'].to_i,
      force: ENV['force'].to_i.nonzero?,
      include_type: {
        challenger: ENV['include_challenger'].to_i.nonzero?,
        junior: ENV['include_junior'].to_i.nonzero?,
      }
    }
    accept_categories = ENV['accept_categories'].to_s.split(/ *, */).map(&:to_sym) if ENV['accept_categories']
    
    updater = Fisk8ResultViewer::Competition::Updater.new
    items = updater.load_competition_list(Rails.root.join('config', 'competitions.yml'))
    [:challenger, :junior].each do |type|
      items += updater.load_competition_list(Rails.root.join('config', "competitions_#{type}.yml")) if options[:include_type][type]
    end
    items = items.last(options[:last]).reverse if options[:last] > 0
    items.each do |item|
      Competition.where(site_url: item[:url]).map(&:destroy) if options[:force]
      updater.update_competition(item[:url], parser_type: item[:parser_type], comment: item[:comment], accept_categories: accept_categories)
    end
  end
end
