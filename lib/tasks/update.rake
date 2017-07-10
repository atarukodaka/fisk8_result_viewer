namespace :update do
  desc "update skater"
  task :skaters  => :environment do
    Skater.create_skaters   ## TODO: accept_categories
  end

  desc "update competitions listed in config/competitions.yml"
  task :competitions => :environment do
    last =  ENV['last'].to_i if ENV['last']
    force =  ENV['force'].to_i.nonzero?

    if ary = ENV['accept_categories']
      Category.accept_to_update(ary.split(/,/))
    end

    ## TODO: full_path??
    if f = ENV['filenames']
      CompetitionList.use_multiple_files
      CompetitionList.set_filenames *(f.split(/,/))
    elsif f = ENV['filename']
      CompetitionList.filename = f
    end
    #list = (last) ? CompetitionList.last(last).reverse : CompetitionList.all
    list = CompetitionList.all
    list = list.last(last).reverse if last
      
    list.each do |item|
      #Competition.destroy_existings_by_url(item[:url]) if force
      Competition.create_competition(item[:url], parser_type: item[:parser_type], comment: item[:comment], force: force)
    end
  end
  
  desc "update competition of given url"
  task :competition => :environment do
    url = ENV['url'] || raise
    force = ENV['force'].to_i.nonzero?
    comment = ENV['comment']
    parser_type = (t = ENV['parser_type']) ? t.to_sym :  :isu_generic

    Competition.destroy_existings_by_url(url) if force
    Competition.create_competition(url, parser_type: parser_type, comment: comment)
  end

=begin
  desc 'show elements'
  task :show_elements => :environment do
    category = ENV['category'] || "MEN"
    puts Element.joins(:score).where("scores.category" => category).map {|e| [e.element_type, e.name]}.uniq.sort {|a, b| a[0]<=>b[0]}.map {|d| d.join(', ')}
  end
=end  
  ################################################################
end  # namespace
