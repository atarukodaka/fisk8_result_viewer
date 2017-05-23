lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require_relative 'config/application'

Rails.application.load_tasks
require 'rake/clean'
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new("spec")
  

task :test => :spec

################
require 'fisk8viewer/updater'

task :update => [:update_skaters, :update_competitions] do
end

task :update_skaters => :environment do
  updater = Fisk8Viewer::Updater::SkatersUpdater.new
  updater.update_skaters(ENV['categories'])
end

task :update_competitions => :environment do
  first = ENV["first"].to_i
  last = ENV["last"].to_i
  #reverse = ENV['reverse'].to_i.nonzero?
  force = ENV['force'].to_i.nonzero?
  updater = Fisk8Viewer::Updater::CompetitionUpdater.new(accept_categories: ENV['accept_categories'])
  items = updater.class.load_competition_list(File.join(Rails.root, "config/competitions.yaml"))

  if first > 0
    items = items.first(first)
  elsif last > 0
    items = items.last(last).reverse
  end
  items.map do |item|
    updater.update_competition(item[:url], parser_type: item[:parser], force: force)
  end
end

task :count_check => :environment do
  ## skaters
  num_skaters = Skater.count
  num_skaters_having_score = Skater.having_scores.count
  puts "skaters: #{num_skaters_having_score} / #{num_skaters}"
  
  # competitions
  Competition.all.each do |competition|
    puts competition.name
    puts "  category_result: #{competition.category_results.count}: #{competition.category_results.group(:category).count}"
    [:short, :free].each do |sf|
      puts "  #{sf} scores:    #{competition.scores.where('segment like ?', '#{sf.to_s.upcase}%').count}: #{competition.scores.where('segment like ?', '#{fs.to_s.upcase}%').group(:category).count}"
    end
  end
end


