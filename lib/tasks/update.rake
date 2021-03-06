namespace :update do
  desc 'update skaters'
  task skaters: :environment do
    Message.silent = ENV['silent'].to_i.nonzero?
    SkaterUpdater.new.update_skaters # (details: details)
  end

  desc 'update skater detail'
  task skater_detail: :environment do
    isu_number = ENV['isu_number'] || raise('no isu_number given')
    Message.silent = ENV['silent'].to_i.nonzero?
    SkaterUpdater.new.update_skater_detail(isu_number)
  end

  desc 'update all skaters detail'
  task skaters_detail: :environment do
    Message.silent = ENV['silent'].to_i.nonzero?
    options = { active_only: ENV['active_only'].to_i.nonzero? }
    SkaterUpdater.new.update_skaters_detail(options)
  end
  ################
  def options_from_env
    {
      last: (ENV.include?('last')) ? ENV['last'].to_i : nil,
      reverse: ENV['reverse'].to_i.nonzero?,
      filename: ENV['filename'],
      force: ENV['force'].to_i.nonzero?,
      categories: (ENV['categories'].nil?) ? nil : ENV['categories'].to_s.split(/\s*,\s?/),
      enable_judge_details: ENV['enable_judge_details'].to_i.nonzero?,
      verbose: ENV['verbose'].to_i.nonzero?,
      silent: ENV['silent'].to_i.nonzero?,
      season: ENV['season'],
      season_from: ENV['season_from'],
      season_to: ENV['season_to'],
      competition_class: ENV['competition_class'],
    }
  end

  desc 'update competition'
  task competition: :environment do
    options = options_from_env
    options[:parser_type] = ENV['parser_type']
    Message.silent = options[:silent]
    CompetitionUpdater.new.update_competition(ENV['site_url'], options)
  end

  desc 'update competitions listed in config/competitions.yml'
  task competitions: :environment do
    env_options = options_from_env
    CompetitionList.filename = env_options[:filename] if env_options[:filename].present?

    list = CompetitionList.all
    if env_options[:last].present?
      list = list.last(env_options[:last]).reverse
    elsif env_options[:reverse]
      list.reverse!
    end

    Message.silent = env_options[:silent]
    list.each do |item|
      options = env_options.merge(item.attributes.slice(:parser_type, :encoding))
      #DebugPrint.verbose = options[:verbose]
      options[:attributes] = item.attributes.slice(:key, :city, :name, :comment).compact
      CompetitionUpdater.new.update_competition(item[:site_url], options)
    end ## each
  end ## task
end # namespace
