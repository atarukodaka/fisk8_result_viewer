module CompetitionParser
  class IsuGeneric
    class SegmentResultParser < ResultParser
      def callbacks
        super.merge(starting_number: lambda {|elem|
                      elem.text.sub(/^#/, '').to_i
                    })
      end
      def columns
        {
          ranking: { header: ['Pl.', 'PL'] },
          name: { header: "Name" },
          nation: { header: "Nation" },
          starting_number: { header: "StN.", callback: callbacks[:starting_number] },
          isu_number: { header: "Name", callback: callbacks[:isu_number] },
        }
      end
    end ## class
  end
end
