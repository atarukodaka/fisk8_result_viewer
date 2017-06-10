module Fisk8ResultViewer
  module Skater
    class Updater
      include Utils
      def update_skaters(categories: [:MEN, :LADIES, :PAIRS, :"ICE DANCE"])
        parser = Fisk8ResultViewer::Skater::Parser.new
        parser.parse_skaters(categories).each do |data|
          ::Skater.find_or_create_by(isu_number: data[:isu_number]) do |skater|
            skater.update!(data)
            puts "create skater in #{skater.category}: #{skater.name} (#{skater.isu_number}) [#{skater.nation}]"
          end
        end
      end
    end
  end
end
