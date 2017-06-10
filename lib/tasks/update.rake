namespace :update do
  desc "update skater"
  task :skaters  => :environment do
    updater = Fisk8ResultViewer::Skater::Updater.new
    updater.update_skaters
  end

  desc "update competitions listed in config/competitions.yml"
  task :competitions => :environment do
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
    parser_type = ENV['parser_type'].to_sym || :isu_generic

    Competition.where(site_url: url).map(&:destroy) if force
    updater = Fisk8ResultViewer::Competition::Updater.new
    updater.update_competition(url, parser_type: parser_type, comment: comment)
  end

  desc "parse score of given url"
  task :parse_score => :environment do
    url = ENV['url']
    parser = Fisk8ResultViewer::Score::Parser.new
    parser.parse_scores(url).each do |score|
      parser.show(score)
    end
  end

  task :clear => :clear_score_graphs
  task :clear_score_graphs => :environment do
    FileUtils.rm(Dir.glob(File.join(ScoreGraph::ImageDir, "*_plot.png")))
  end

  ################################################################
  namespace :check do
    desc "check number of scores registered"
    task :count => :environment do
      ## skaters
      num_skaters = Skater.count
      num_skaters_having_score = Skater.having_scores.count
      puts "skaters: #{num_skaters_having_score} / #{num_skaters}"

      # competitions
      Competition.all.each do |competition|
        puts "#{competition.name} (#{competition.site_url})"
        puts "  category_result: #{competition.category_results.count}: #{competition.category_results.group(:category).count}"
        [:short, :free].each do |sf|
          puts "  #{sf} scores:    #{competition.scores.where('segment like ?', "#{sf.to_s.upcase}%").count}: #{competition.scores.where('segment like ?', "#{sf.to_s.upcase}%").group(:category).count}"
        end
      end
    end
    desc "check elements/components details"
    task :elements => :environment do
      [Element, Component].each do |model|
        Score.where.not(id: model.select(:score_id).group(:score_id).having("count(score_id) > 0")).each do |score|
          puts "!!! #{score.sid} has no #{model.pluralize} at all"
        end
      end
      puts "done."
    end
  end
  
end  # namespace
