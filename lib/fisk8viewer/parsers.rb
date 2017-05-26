module Fisk8Viewer
  module Parsers
    @registered = {}
    
    class << self
      attr_reader :registered
      def register(key, klass)
        @registered[key] = klass
      end
    end
  end
end

## require all rb files under ./parsers
Dir[File.expand_path('../parsers', __FILE__) << '/*.rb'].each do |file|
  require file
end

#ActiveSupport::Dependencies.autoload_paths << "lib/fisk8viewer/parsers"
=begin
require 'fisk8viewer/parsers/isu_generic'
require 'fisk8viewer/parsers/isu_generic_mdy'
require 'fisk8viewer/parsers/wtt_2017'
require 'fisk8viewer/parsers/finlandia'
=end
