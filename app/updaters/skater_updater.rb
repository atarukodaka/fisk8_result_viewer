class SkaterUpdater < Updater
  using StringToModel

  def parser
    @parser ||= SkaterParser.new
  end

  def update_skaters
    CategoryType.all.each do |category_type|
      message("#{category_type.name}: #{category_type.isu_bio_url}")

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
    end
  end

  ################
  # skater detail
  def update_skaters_detail(options = {})
    Skater.find_each.reject { |sk| sk.isu_number.blank? }.map do |skater|
      next if options[:active_only] && skater.category_results.count == 0

      update_skater_detail(skater.isu_number)
    end
  end

  def update_skater_detail(isu_number)
    skater = Skater.find_or_create_by(isu_number: isu_number)
    message("#{skater.name}[#{skater.isu_number}]...")
    details_hash = parser.parse_skater_details(skater.isu_number)

    message('   %s' %
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
