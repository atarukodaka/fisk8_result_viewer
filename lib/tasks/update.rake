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
      categories: ENV['categories'].to_s.split(/\s*,\s?/),
      enable_judge_details: ENV['enable_judge_details'].to_i.nonzero?,
      quiet: ENV['quiet'].to_i.nonzero?,
      season_from: ENV['season_from'],
      season_to: ENV['season_to'],

      date_format: ENV['date_format'],
    }
  end

  def update_competition(site_url, parser_type:, options:, params:)
    CompetitionUpdater.new(parser_type: parser_type, verbose: !options[:quiet],
                           enable_judge_details: options[:enable_judge_details])
      .update_competition(site_url, date_format: options[:date_format], force: options[:force],
                          season_from: options[:season_from], season_to: options[:season_to],
                          categories: options[:categories], params: params)
  end
  desc 'update competition'
  task competition: :environment do
    options = options_from_env
    params = ENV.to_hash.slice(:city, :name, :comment)
    update_competition(ENV['site_url'], parser_type: ENV['parser_type'], options: options, params: params)
  end

  desc 'update competitions listed in config/competitions.yml'
  task competitions: :environment do
    options = options_from_env

    ## options
    CompetitionList.filename = options[:filename] if options[:filename].present?

    list = CompetitionList.all
    list = list.last(options[:last]).reverse if options[:last].present?

    list.each do |item|
      params = item.attributes.slice(:city, :name, :comment)
      update_competition(item[:site_url], parser_type: item[:parser_type], options: options, params: params)
    end ## each
    DeviationsUpdater.new(verbose: true).update_deviations if options[:enable_judge_details]
  end ## task

  ################
  desc 'update deviation'
  task deviations: :environment do
    quiet = ENV['quiet'].to_i.nonzero?
    DeviationsUpdater.new(verbose: !quiet).update_deviations
  end
end # namespace
