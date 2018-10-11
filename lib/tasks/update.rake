namespace :update do
  desc 'update skaters'
  task skaters: :environment do
    quiet = ENV['quiet'].to_i.nonzero?
    SkaterUpdater.new(verbose: !quiet).update_skaters # (details: details)
  end

  desc 'update skater detail'
  task skater_detail: :environment do
    isu_number = ENV['isu_number'] || raise('no isu_number given')
    quiet = ENV['quiet'].to_i.nonzero?
    SkaterUpdater.new(verbose: !quiet).update_skater_detail(isu_number)
  end

  desc 'update all skaters detail'
  task skaters_detail: :environment do
    quiet = ENV['quiet'].to_i.nonzero?
    SkaterUpdater.new(verbose: !quiet).update_skaters _detail
  end
  ################
  def options_from_env
    {
      last: (ENV.include?('last')) ? ENV['last'].to_i : nil,
      filename: ENV['filename'],
      force: ENV['force'].to_i.nonzero?,
      categories: (ENV['categories'].present?) ? ENV['categories'].to_s.split(/\s*,\s?/) : nil,
      enable_judge_details: ENV['enable_judge_details'].to_i.nonzero?,
      quiet: ENV['quiet'].to_i.nonzero?,
      season_from: ENV['season_from'],
      season_to: ENV['season_to'],
    }
  end

  desc 'update competition'
  task competition: :environment do
    options = options_from_env
    options[:params] = ENV.to_hash.slice(:city, :name, :comment)
    options[:parser_type] = ENV['parser_type']
    options[:date_format] =  ENV['date_format']
    CompetitionUpdater.new(verbose: !options[:quiet]).update_competition(ENV['site_url'], options)
  end

  desc 'update competitions listed in config/competitions.yml'
  task competitions: :environment do
    options = options_from_env

    ## options
    CompetitionList.filename = options[:filename] if options[:filename].present?

    list = CompetitionList.all
    list = list.last(options[:last]).reverse if options[:last].present?

    list.each do |item|
      options[:params] = item.attributes.slice(:city, :name, :comment)
      options[:parser_type] = item[:parser_type]
      CompetitionUpdater.new(verbose: !options[:quiet]).update_competition(item[:site_url], options)
    end ## each
  end ## task
end # namespace
