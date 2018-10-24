# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

################
# stackprof
if ENV['ENABLE_STACKPROF'].to_i.nonzero?
  opts = {
    enabled:    true,
    raw: true,
    mode: (ENV['STACKPROF_MODE'] || :wall).to_sym,
    interval:   (ENV['STACKPROF_INTERVAL']   || 1000).to_i,
    save_every: (ENV['STACKPROF_SAVE_EVERY'] || 1).to_i,
    path:       (ENV['STACKPROF_PATH'] || 'tmp/stackprof/'),
  }
  use StackProf::Middleware, opts
end

run Rails.application
