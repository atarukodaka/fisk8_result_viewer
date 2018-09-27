namespace :update do
  desc "update skater"
  task :skaters  => :environment do
    details = ENV['details'].to_i.nonzero?
    
    SkaterUpdater.new(verbose: true).update_skaters(details: details)
  end

  ################
  desc "update competitions listed in config/competitions.yml"
  task :competitions => :environment do
    ## options
    last =  ENV['last'].to_i if ENV['last']
    force =  ENV['force'].to_i.nonzero?

    categories = 
      if (c = ENV['categories'])
        c.to_s.split(/\s*,\s*/).map do |cat|
          Category.where(name: cat).first
        end.compact
      else
        Category.all
      end
    if (f = ENV['filename'])
      CompetitionList.filename = f
    end
    enable_judge_details = ENV['enable_judge_details'].to_i.nonzero?

    ################
    list = CompetitionList.all
    list = list.last(last).reverse if last

    list.each do |item|
      ActiveRecord::Base.transaction do
        params = {
          city: item[:city], name: item[:name], comment: item[:comment]
        }
        CompetitionUpdater.new(parser_type: item[:parser_type], verbose: true, enable_judge_details: enable_judge_details).
          update_competition(item[:site_url], date_format: item[:date_format], force: force, categories: categories, params: params).tap do |competition|
        end
      end
    end  ## each
  end ## task

  ################
  desc 'update deviation'
  task :deviations => :environment do
    data = {}
    ElementJudgeDetail.joins(:element, :official).group("elements.score_id").group("officials.panel_id").sum(:abs_deviation).each do |key, value|
      data[key] ||= {}
      data[key][:tes] = value
    end
    ComponentJudgeDetail.joins(:component, :official).group("components.score_id").group("officials.panel_id").sum(:deviation).each do |key, value|
      data[key] ||= {}
      data[key][:pcs] = value
    end
    scores = Score.all.index_by(&:id)  ## TODO: use memory too much ??
    
    ActiveRecord::Base.transaction do
      data.each do |(score_id, panel_id), hash|
        #puts [score_id, panel_id, hash[:tes], hash[:pcs]].join(', ')
        Deviation.find_or_create_by(score_id: score_id, panel_id: panel_id).tap do |deviation|
          n_elements = scores[score_id].elements.count

          deviation.attributes = {
            tes_deviation: hash[:tes],
            pcs_deviation: hash[:pcs],
            tes_ratio: hash[:tes] / n_elements,
            pcs_ratio: hash[:pcs] / 7.5,
            official: Official.where(performed_segment: scores[score_id].performed_segment, panel_id: panel_id).first,
            num_elements: n_elements,  ## TODO: necessary ?
          }
          deviation.save!
        end
      end
    end
  end
end  # namespace
