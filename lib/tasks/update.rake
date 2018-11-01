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
    SkaterUpdater.new(verbose: !quiet).update_skaters_detail
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
      quiet: ENV['quiet'].to_i.nonzero?,
      season_from: ENV['season_from'],
      season_to: ENV['season_to'],
    }
  end

  desc 'update competition'
  task competition: :environment do
    options = options_from_env
    # options[:params] = ENV.to_hash.slice(:city, :name, :comment)
    options[:parser_type] = ENV['parser_type']
    options[:date_format] =  ENV['date_format']
    CompetitionUpdater.new(verbose: !options[:quiet]).update_competition(ENV['site_url'], options)
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

    list.each do |item|
      options = env_options.dup
      options.merge!(item.attributes.slice(:date_format, :parser_type))
      CompetitionUpdater.new(verbose: !options[:quiet])
        .update_competition(item[:site_url], options) do |competition|
        item.attributes.slice(:city, :name, :comment).each do |key, value|
          competition.update(key => value) if value.present?
        end
      end
    end ## each
  end ## task

  desc 'update gps'
  task grandprix: :environment do
    using StringToModel
    season = '2018-19'.to_season

    #['MEN', 'LADIES', 'PAIRS', 'ICE DANCE'].each do |key|
    ['MEN', 'LADIES', 'PAIRS'].each do |key|
      category = key.to_category
      GrandprixUpdater.new(verbose: true).update(season, category)
    end
  end
end # namespace
