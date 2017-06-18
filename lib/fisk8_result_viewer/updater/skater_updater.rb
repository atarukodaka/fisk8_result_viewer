module Fisk8ResultViewer
  module Updater
    class SkaterUpdater

      include Utils
      def initialize(quiet: false)
        @quiet = quiet
      end
      
      def update_skaters(categories: nil)
        categories ||= [:MEN, :LADIES, :PAIRS, :"ICE DANCE"]
        parser = Fisk8ResultViewer::Parser::SkaterParser.new
        parser.parse_skaters(categories).each do |data|
          ::Skater.find_or_create_by(isu_number: data[:isu_number]) do |skater|
            skater.update!(data)
            puts "create skater in #{skater.category}: #{skater.name} (#{skater.isu_number}) [#{skater.nation}]"
          end
        end
      end

      def dputs(*args)
        puts args unless @quiet
      end
    end
  end
end
