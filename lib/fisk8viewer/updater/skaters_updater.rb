module Fisk8Viewer
  module Updater
    class SkatersUpdater
      include FindSkater
      
      def update_skaters(categories = [:MEN, :LADIES, :PAIRS, :"ICE DANCE"])
        categories = categories.split(/ *, */).map(&:upcase).map(&:to_sym) if categories.class == String
        parser = Fisk8Viewer::ISU_Bio.new
        ActiveRecord::Base::transaction do
          parser.parse_isu_bio_summary(categories).each do |hash|
            find_or_create_skater(hash[:isu_number], hash[:name], category: hash[:category], nation: hash[:nation])
          end
        end
      end
    end
  end
end
  
=begin
#require 'fisk8viewer/isu_bio'
    def update_isu_bio_details(skater=nil)
      puts("update skaters bio details")

      skaters = (skater.present?) ? [skater] : Skater.order(:category)
      
      parser = Fisk8Viewer::ISU_Bio.new
      skaters.each do |skater|
        next if skater.isu_number.blank?
        next if skater.category != "MEN" && skater.category != "LADIES"
        next unless @accept_categories.include?(skater.category.to_sym)
        #next if skater.bio_updated_at.present?
        
        hash = parser.parse_isu_bio_details(skater.isu_number, skater.category)
        puts("  update skater bio: #{hash[:name]} (#{skater.isu_number})")        
        keys = [:isu_number, :name, :nation, :category, # :isu_bio,
                :coach, :choreographer, :birthday, :hobbies, :height, :club]
        ActiveRecord::Base::transaction do
          skater.update!(hash.slice(*keys))
          skater.update!(bio_updated_at: Time.now)
        end
      end
    end
=end
