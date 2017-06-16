namespace 'check' do
  desc "check number of scores registered"
  task :count => :environment do
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
  desc "check elements/components details"
  task :elements => :environment do
    [Element, Component].each do |model|
      Score.where.not(id: model.select(:score_id).group(:score_id).having("count(score_id) > 0")).each do |score|
        puts "!!! #{score.name} has no #{model.pluralize} at all"
      end
    end
    puts "done."
  end
end
