# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)


require_relative 'config/application'

Rails.application.load_tasks
require 'rake/clean'
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new("spec")
task :test => :spec do
end

  
################
require 'fisk8viewer/updater'

task :update => [:update_skaters, :update_competitions] do
end

task :update_skaters => :environment do
  updater = Fisk8Viewer::Updater.new(accept_categories: ENV['accept_categories'])
  updater.update_skaters
end

task :update_competitions => :environment do
  first = ENV["first"].to_i
  last = ENV["last"].to_i
  #reverse = ENV['reverse'].to_i.nonzero?
  force = ENV['force'].to_i.nonzero?
  updater = Fisk8Viewer::Updater.new(accept_categories: ENV['accept_categories'], force: force)
  items = updater.load_competition_list(File.join(Rails.root, "config/competitions.yaml"))

  if first > 0
    items = items.first(first)
  elsif last > 0
    items = items.last(last).reverse
  end
  updater.update_competitions(items)
end
