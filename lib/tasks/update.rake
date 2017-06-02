require 'fisk8viewer/updater'

namespace :update do
  desc "update skaters"
  task :skaters => :environment do
    updater = Fisk8Viewer::Updater::SkatersUpdater.new
    updater.update_skaters(ENV['categories'])
  end

  task :competitions => :environment do
    first = ENV["first"].to_i
    last = ENV["last"].to_i
    force = ENV['force'].to_i.nonzero?
    include_competition_type = {
      challenger: ENV['include_challenger'].to_i.nonzero?,
      junior: ENV['include_junior'].to_i.nonzero?,
    }
    updater = Fisk8Viewer::Updater::CompetitionUpdater.new(accept_categories: ENV['accept_categories'])
    items = updater.class.load_competition_list(File.join(Rails.root, "config/competitions.yml"))
    include_competition_type.each do |key, value|
      items += updater.class.load_competition_list(File.join(Rails.root, "config/competitions_#{key}.yml")) if value
    end
    if first > 0
      items = items.first(first)
    elsif last > 0
      items = items.last(last).reverse
    end
    items.map do |item|
      Competition.destroy_existings_by_url(item[:url]) if force
      updater.update_competition(item[:url], parser_type: item[:parser], comment: item[:comment])
    end
  end

  task :count_check => :environment do
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
  task :clear_score_graphs => :environment do
    FileUtils.rm(Dir.glob(File.join(ScoreGraph::ImageDir, "*_plot.png")))
  end

  task :elements_check => :environment do
    Score.where.not(id: Element.select(:score_id).group(:score_id).having("count(score_id) > 0")).each do |score|
      puts "!!! #{score.sid} has no elements at all"
    end
    Score.where.not(id: Component.select(:score_id).group(:score_id).having("count(score_id) > 0")).each do |score|
      puts "!!! #{score.sid} has no components at all"
    end
    
  end
end  # namespace
