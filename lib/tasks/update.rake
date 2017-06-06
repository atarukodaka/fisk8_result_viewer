namespace :update do
  desc "update skater"
  task :skaters  => :environment do
    categories = [:MEN]
    updater = Fisk8ResultViewer::Skater::Updater.new
    updater.update_skaters(categories: [:MEN])
  end

  desc "update competitions listed in config/competitions.yml"
  task :competitions => :environment do
    options = {
      last: ENV['last'].to_i,
      force: ENV['force'].to_i.nonzero?,
      include_type: {
        challenger: ENV['include_challenger'].to_i.nonzero?,
        junior: ENV['include_junior'].to_i.nonzero?,
      }
    }
    accept_categories = ENV['accept_categories'].to_s.split(/ *, */).map(&:to_sym) if ENV['accept_categories']
    
    updater = Fisk8ResultViewer::Competition::Updater.new
    items = updater.load_competition_list(Rails.root.join('config', 'competitions.yml'))
    [:challenger, :junior].each do |type|
      items += updater.load_competition_list(Rails.root.join('config', "competitions_#{type}.yml")) if options[:include_type][type]
    end
    items = items.last(options[:last]).reverse if options[:last] > 0
    items.each do |item|
      Competition.where(site_url: item[:url]).map(&:destroy) if options[:force]
      updater.update_competition(item[:url], parser_type: item[:parser_type], comment: item[:comment], accept_categories: accept_categories)
    end
  end

  desc "update competition of given url"
  task :competition => :environment do
    url = ENV['url']
    force = ENV['force'].to_i.nonzero?
    parser_type = ENV['parser_type'] || :isu_generic

    Competition.where(site_url: url).map(&:destroy) if force
    updater = Fisk8ResultViewer::Competition::Updater.new
    updater.update_competition(url, parser_type: parser_type)
  end

  desc "parse score of gievn url"
  task :parse_score => :environment do
    url = ENV['url']
    Fisk8ResultViewer::Score::Parser.new.parse_scores(url).each do |score|
      puts "-" * 100
      puts "%d %s [%s] %d  %6.2f = %6.2f + %6.2f + %2d" % 
        [score[:ranking], score[:skater_name], score[:nation], score[:starting_number],
         score[:tss], score[:tes], score[:pcs], score[:deductions],
        ]
      puts "Executed Elements"
      score[:elements].each do |element|
        puts "  %d %-20s %-3s %5.2f %5.2f %-30s %6.2f" %
          [element[:number], element[:name], element[:info], element[:base_value],
           element[:goe], element[:judges].split(/\s/).map {|v| "%4d" % [v]}.join(' '),
           element[:value]]
      end
      puts "Program Components"
      score[:components].each do |component|
        puts "  %d %-31s %3.2f %-15s %6.2f" %
          [component[:number], component[:name], component[:factor],
           component[:judges], component[:value]]
      end
      if score[:deduction_reasons]
        puts "Deductions"
        puts "  " + score[:deduction_reasons]
      end
    end
  end

  desc "check number of scores registered"
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

  desc "check elements/components details"
  task :elements_check => :environment do
    Score.where.not(id: Element.select(:score_id).group(:score_id).having("count(score_id) > 0")).each do |score|
      puts "!!! #{score.sid} has no elements at all"
    end
    Score.where.not(id: Component.select(:score_id).group(:score_id).having("count(score_id) > 0")).each do |score|
      puts "!!! #{score.sid} has no components at all"
    end
    puts "done."
  end
  
end  # namespace
