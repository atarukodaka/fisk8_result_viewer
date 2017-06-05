module Fisk8ResultViewer
  module Skater
    module FindSkater
      def find_skater(isu_number, skater_name)
        (::Skater.find_by(isu_number: isu_number) if isu_number.present?) ||
          ::Skater.find_by(name: skater_name)
      end
      def find_or_create_skater(isu_number, name)
        find_skater(isu_number, name) || ::Skater.create do |skater|
          skater.isu_number = isu_number
          skater.name = name
          yield(skater)
        end
      end
      def correct_skater_name(skater_name)
        filename = Rails.root.join('config', 'skater_name_correction.yml')
        @_skater_corrections ||= YAML.load_file(filename)
        skater_name = @_skater_corrections[skater_name] if @_skater_corrections.has_key?(skater_name)
        skater_name
      end
    end
  end
end
