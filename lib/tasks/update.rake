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
    #reverse = ENV['reverse'].to_i.nonzero?
    force = ENV['force'].to_i.nonzero?
    updater = Fisk8Viewer::Updater::CompetitionUpdater.new(accept_categories: ENV['accept_categories'])
    items = updater.class.load_competition_list(File.join(Rails.root, "config/competitions.yml"))

    if first > 0
      items = items.first(first)
    elsif last > 0
      items = items.last(last).reverse
    end
    items.map do |item|
      Competition.destroy_existings_by_url(item[:url]) if force
      updater.update_competition(item[:url], parser_type: item[:parser], attributes: item[:attributes])
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
end
