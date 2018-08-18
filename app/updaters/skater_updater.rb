class SkaterUpdater
  def update_skaters
    
    parser = SkaterParser.new
    ActiveRecord::Base.transaction do
      Category.all.select(&:isu_bio_url).each do |category|
        binding.pry
        parser.parse_skaters(category.name, category.isu_bio_url).each do |hash|
          Skater.find_or_create_by(isu_number: hash[:isu_number]) do |skater|
            skater.update(hash)
          end
        end
      end
    end  # transaction
  end
end
