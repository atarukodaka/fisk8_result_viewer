module Fisk8Viewer
  module Updater
    module FindSkater
      def seniorize(category)
        sen_cat = category.to_s.gsub(/^JUNIOR /, '')
        (category.class == Symbol) ? sen_cat.to_sym : sen_cat
      end
      def find_skater_by_isu_number_name(isu_number, name)
        skater = Skater.find_by(isu_number: isu_number) if isu_number.present?
        skater ||= Skater.find_by(name: name)      
      end
      def find_or_create_skater(isu_number, name, nation:, category:)
        find_skater_by_isu_number_name(isu_number, name) || Skater.create do |skater|
          skater.isu_number = isu_number
          #skater.isu_bio = isu_bio_url(isu_number) if isu_number.present?
          skater.name = name
          skater.nation = nation
          skater.category = seniorize(category)
          puts " ! '%{name}' (%{isu_number}) [%{nation}] <%{category}> created" % skater.attributes.symbolize_keys
        end
      end
    end
  end
end
