lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require_relative 'config/application'

Rails.application.load_tasks
require 'rake/clean'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec')

task test: :spec
