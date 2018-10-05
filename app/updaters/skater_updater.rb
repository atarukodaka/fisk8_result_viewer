class SkaterUpdater
  include DebugPrint

  def initialize(verbose: false)
    @verbose = verbose
  end

  def parser
    @parser ||= SkaterParser.new
  end

  def update_skaters
    Category.having_isu_bio.each do |category|
      debug("#{category.name}: #{category.isu_bio_url}")

      ActiveRecord::Base.transaction do
        parser.parse_skaters(category.name, category.isu_bio_url).each do |hash|
          hash[:category] = Category.find_by(name: hash[:category])
          Skater.find_or_create_by(isu_number: hash[:isu_number]) do |skater|
            attrs = [:name, :category, :nation, :isu_number]
            skater.update(hash.slice(*attrs))
          end
        end
      end # transaction
    end
  end

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
      skater.update(category: Category.find_by(name: details_hash[:category]))
    end
  end
end ## class
