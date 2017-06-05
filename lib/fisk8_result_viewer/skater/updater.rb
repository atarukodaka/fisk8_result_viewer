module Fisk8ResultViewer
  module Skater
    class Updater
      def update_skaters(categories: [:MEN, :LADIES, :PAIRS, :"ICE DANCE"])
        parser = Fisk8ResultViewer::Skater::Parser.new
        parser.parse_skaters(categories).each do |data|
          Skater.find_or_create_by(isu_number: data[:isu_number]) do |skater|
            puts ("create skater: #{skater.name} (#{skater.isu_number})")
            skater.update!(data)
          end
        end
      end
    end
  end
end
