class SkaterUpdater < Updater
  using StringToModel

  def parser
    @parser ||= SkaterParser.new
  end

  def update_skaters
    CategoryType.all.each do |category_type|
      debug("#{category_type.name}: #{category_type.isu_bio_url}")

      ActiveRecord::Base.transaction do
        parser.parse_skaters(category_type.name, category_type.isu_bio_url).each do |hash|
          #hash[:category] = hash[:category].to_category
          hash[:category_type] = category_type
          Skater.find_or_create_by(isu_number: hash[:isu_number]) do |skater|
            attrs = [:name, :category_type, :nation, :isu_number]
            skater.update(hash.slice(*attrs))
          end
        end
      end # transaction
    end
  end
=begin
  def update_skaters
    Category.having_isu_bio.each do |category|
      debug("#{category.name}: #{category.isu_bio_url}")

      ActiveRecord::Base.transaction do
        parser.parse_skaters(category.name, category.isu_bio_url).each do |hash|
          hash[:category] = hash[:category].to_category
          Skater.find_or_create_by(isu_number: hash[:isu_number]) do |skater|
            attrs = [:name, :category, :nation, :isu_number]
            skater.update(hash.slice(*attrs))
          end
        end
      end # transaction
    end
  end
=end

  ################
  # skater detail
  def update_skaters_detail
    Skater.reject { |sk| sk.isu_number.blank? }.each do |skater|
      update_skater_detail(skater.isu_number)
    end
  end

  def update_skater_detail(isu_number)
    skater = Skater.find_or_create_by(isu_number: isu_number)

    details_hash = parser.parse_skater_details(skater.isu_number)
    debug("#{skater.name} [#{skater.isu_number}]:  club: #{details_hash[:club]}, coach: #{details_hash[:coach]}")

    ActiveRecord::Base.transaction do
      attrs = [:name, :nation, :height, :birthday, :hometown, :club, :hobbies,
               :coach, :choreographer, :bio_updated_at]
      skater.update(details_hash.slice(*attrs))
      skater.update(category_type: details_hash[:category_type].to_category_type)
    end
  end
end ## class
