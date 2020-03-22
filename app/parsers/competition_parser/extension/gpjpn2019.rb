class CompetitionParser
  module Extension
    class Gpjpn2019 < CompetitionParser::Extension::Gpjpn
      class SegmentResultParser < CompetitionParser::SegmentResultParser
        def find_column(from:, headers:, to_match:)
          col_number = headers.index { |d| d =~ to_match } || return  #|| raise("no relevant column: from #{from}, headers: #{headers}, to match: #{to_match}")
          ## gpjpn2019 has useless TD with display:none, so add +1 to ignore it. shxt jsf
          from[col_number + 1]
        end
      end
    end
  end
end
