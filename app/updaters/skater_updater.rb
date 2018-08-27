class SkaterUpdater
  def initialize(verbose: false)
    @verbose = verbose
  end
  
  def update_skaters(details: false)
    parser = SkaterParser.new

    Category.all.select(&:isu_bio_url).each do |category|
      ActiveRecord::Base.transaction do
        parser.parse_skaters(category.name, category.isu_bio_url).each do |hash|
          Skater.find_or_create_by(isu_number: hash[:isu_number]) do |skater|
            skater.update(hash)
          end
        end
      end  # transaction             
    end

    if details
      Skater.all.each do |skater|
        details_hash = parser.parse_skater_details(skater.isu_number)
        puts "#{skater.name} [#{skater.isu_number}]:  club: #{details_hash[:club]}, coach: #{details_hash[:coach]}" if @verbose
        
        ActiveRecord::Base.transaction do
          skater.update(details_hash)
        end
      end
    end
  end
end
