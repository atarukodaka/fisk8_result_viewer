namespace :update do
  task :skaters_model => :environment do

  end
  
  desc "update skater"
  task :skaters  => :environment do
    Skater.create_skaters_from_isu_bio   ## TODO: accept_categories
=begin
    include Fisk8ResultViewer::Utils
    accept_categories = str2symbols(ENV['accept_categories']) if ENV['accept_categories']
    updater = Fisk8ResultViewer::Updater::SkaterUpdater.new
    updater.update_skaters(categories: accept_categories)
=end
  end

  desc "update competitions listed in config/competitions.yml"
  task :competitions => :environment do
    last =  ENV['last'].to_i
    force =  ENV['force'].to_i.nonzero?
    accept_categories = ENV['accept_categories'].split(/,/).map(&:to_sym) if ENV['accept_categories']
    #challenger: ENV['include_challenger'].to_i.nonzero?,
    #junior: ENV['include_junior'].to_i.nonzero?,
    
    CompetitionList.new.create_competitions(force: force, last: last, accept_categories: accept_categories) # TODO: include
  end
  
  task :competitions_old => :environment do
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
    
    updater = Fisk8ResultViewer::Updater::CompetitionUpdater.new(accept_categories: accept_categories)
    items = updater.load_competition_list
    [:challenger, :junior].each do |type|
      items += updater.load_competition_list(type: type) if options[:include_type][type]
    end
    items = items.last(options[:last]).reverse if options[:last] > 0
    items.each do |item|
      Competition.where(site_url: item[:url]).map(&:destroy) if options[:force]
      updater.update_competition(item[:url], parser_type: item[:parser_type], comment: item[:comment])
    end
  end

  desc "update competition of given url"
  task :competition => :environment do
    url = ENV['url'] || raise
    force = ENV['force'].to_i.nonzero?
    comment = ENV['comment']
    parser_type = (t = ENV['parser_type']) ? t.to_sym :  :isu_generic

    Competition.destroy_existings_by_url(url) if force
    Competition.create_competition(url, parser_type: parser_type)  ## TODO: comment
  end

  desc 'show elements'
  task :show_elements => :environment do
    binding.pry
    category = ENV['category'] || "MEN"
    puts Element.joins(:score).where("scores.category" => category).map {|e| [e.element_type, e.name]}.uniq.sort {|a, b| a[0]<=>b[0]}.map {|d| d.join(', ')}
  end
  
  ################################################################
end  # namespace
