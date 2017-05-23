

module Fisk8Viewer
  module Updater
    class CategoryAccepter
      DEFAULT_ACCEPT_CATEGORIES =
        [:MEN, :LADIES, :PAIRS, :"ICE DANCE",
         :"JUNIOR MEN", :"JUNIOR LADIES", :"JUNIOR PAIRS", :"JUNIOR ICE DANCE",
        ]
      def initialize(categories)
        @accept_categories =
          case categories
          when String
            categories.split(/ *, */).map(&:upcase).map(&:to_sym)
          when Array
            categories.map(&:to_sym)
          when Symbol
            [categories]
          else
            categories
          end || DEFAULT_ACCEPT_CATEGORIES
      end

      def accept_categories
        @accept_categories
      end

      def accept?(category)
        ## category:
        ##   nil:   all categories accepted
        ##   []:    no categories accepted
        return true if @accept_categories.nil?
        @accept_categories.include?(category.to_sym)
      end
    end
  end
end
