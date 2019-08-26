class SkaterUpdater < Updater
  using StringToModel

  def parser
    @parser ||= SkaterParser.new
  end

  def update_skaters
    CategoryType.all.each do |category_type|
      debug("#{category_type.name}: #{category_type.isu_bio_url}")

      cols = Skater.column_names.map(&:to_sym)
      data = []
      ActiveRecord::Base.transaction do
        parser.parse_skaters(category_type.name, category_type.isu_bio_url).map do |hash|
          data << hash.slice(*cols).merge(category: category_type.name)
          # hash[:category] = hash[:category].to_category
          hash[:category_type] = category_type
          Skater.find_or_create_by(isu_number: hash[:isu_number]) do |skater|
            attrs = [:name, :category_type, :nation, :isu_number]
            skater.update(hash.slice(*attrs))
          end
        end
      end # transaction

#      File.open("config/skaters.yml", "w") do |f|
#        f.puts data.to_yaml
#      end
    end
  end

  ################
  # skater detail
  def update_skaters_detail(options = {})

    cache_filename = "cache/skaters.yml"
    cached_skaters = begin
      YAML.load_file(cache_filename)
    rescue Errno::ENOENT
      []
    end
    skaters = Skater.find_each.reject { |sk| sk.isu_number.blank? }.map do |skater|
      next if options[:active_only] && skater.category_results.count == 0

      if options[:force]
        update_skater_detail(skater.isu_number)
      else
        cached_skater = cached_skaters.select {|d| d["isu_number"] == skater.isu_number}.first
        if cached_skater.blank?
          update_skater_detail(skater.isu_number)
        else
          cached_skater["bio_updated_at"] = cached_skater["bio_updated_at"].in_time_zone
          skater.attributes = cached_skater.except(:id)
          skater.save!
        end
      end
      hash = skater.attributes
      hash["bio_updated_at"] = skater.bio_updated_at.to_s
      hash
    end.compact

    ## store to cache
    File.open("cache/skaters.yml", "w") do |f|
      f.puts skaters.to_yaml
    end
  end

  def update_skater_detail(isu_number)
    skater = Skater.find_or_create_by(isu_number: isu_number)
    debug("#{skater.name}[#{skater.isu_number}]...")
    details_hash = parser.parse_skater_details(skater.isu_number)
    debug("   %s" %
          details_hash.values_at(:club, :coach, :birthday, :bio_updated_at).join('/'))
    ActiveRecord::Base.transaction do
      attrs = [:name, :nation, :height, :birthday, :hometown, :club, :hobbies,
               :coach, :practice_low_season, :practice_high_season, :choreographer, :bio_updated_at]
      skater.update(details_hash.slice(*attrs))
      skater.update(category_type: details_hash[:category_type].to_category_type)
      skater
    end
  end  ## ensure to return skater object
end ## class
