module CompetitionParser
  class IsuGeneric
    class SegmentResultParser < ResultParser
      include Utils
      def parse(url)
        data = super(url)
        data.map do |hash|
          hash[:starting_number] =~ /#(.*)$/
          hash[:starting_number] = $1.to_i
          hash
        end
      end
      def header_mapping
        {
          "Pl." => :ranking,
          "Name" => :skater_name,
          "StN." => :starting_number,
        }
      end
=begin
      def column_type
        {
          ranking: :int,
          skater_name: :string,
          starting_number: :string, ## '#12' => 12 done after
        }
      end
=end
      def first_header_name
        "Pl."
      end
    end ## class
  end
end
