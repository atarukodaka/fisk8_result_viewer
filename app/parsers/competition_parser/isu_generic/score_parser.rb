require 'pdftotext'
require 'tempfile'

class CompetitionParser
  class IsuGeneric
    class ScoreParser < ::Parser
      SCORE_DELIMITER = /Score Score/

      def parse(score_url)
        text = convert_pdf(score_url) || (return [])
        puts "   -- parsing score: #{score_url}" if @verbose

        text.force_encoding('UTF-8').gsub(/  +/, ' ').gsub(/^ */, '').gsub(/\n\n+/, "\n").chomp
          .split(/\f/).map.with_index do |page_text, i|
          page_text.split(SCORE_DELIMITER)[1..-1].map do |t|
            parse_score(t).tap do |score|
              score[:result_pdf] = "#{score_url}\#page=#{i + 1}"
            end
          end
        end.flatten
      end

      def parse_score(text)
        @mode = :skater
        @score = { elements: [], components: [] }

        text.split(/\n/).each do |line|
          begin
            send("parse_#{@mode}", line)
          rescue NameError
            raise "NameError: no such mode: #{@mode}"
          end
        end ## each line

        raise 'parsing error' if @mode != :pcs && @mode != :deductions

        @score
      end

      def parse_skater(line)
        name_re = %q[[[:alpha:]1\.\- \/\']+] ## adding '1' for Mariya1 BAKUSHEVA (http://www.pfsa.com.pl/results/1314/WC2013/CAT003EN.HTM)
        nation_re = '[A-Z][A-Z][A-Z]'
        if line =~ /^(\d+) (#{name_re}) *(#{nation_re}) (\d+) ([\d\.]+) ([\d\.]+) ([\d\.]+) ([\d\.\-]+)/
          @score.update(
            ranking: $1.to_i, skater_name: $2.strip, nation: $3,
            starting_number: $4.to_i, tss: $5.to_f, tes: $6.to_f,
            pcs: $7.to_f, deductions: $8.to_f.abs * (-1)
          )
          @mode = :tes
        end
      end

      def parse_tes(line)
        case line
        when /^(\d+) +(.*)$/
          number = $1.to_i; rest = $2
          element_re = '[\w\+\!<\*]+'
          if rest =~ /(#{element_re}) ([<>\!\*e]*) *([\d\.]+) ([Xx]?) *([\d\.\-]+) ([\d\- ]+) ([\d\.\-]+)$/
            element = {
              number: number, name: $1, info: $2, base_value: $3.to_f,
              credit: $4.downcase, goe: $5.to_f, judges: $6, value: $7.to_f,
            }
            element[:edgeerror] = true if element[:name] =~ /\!/
            if element[:name] =~ /</
              if element[:name] =~ /<</
                element[:downgraded] = true
              else
                element[:underrotated] = true
              end
            end
            @score[:elements] << element
          else
            raise 'parseing error on TES'
          end
        when /^([\d\.]+) +[\d\.]+$/
          @score[:base_value] = $1.to_f
        when /^Program Components/
          @mode = :pcs
        end
      end

      def parse_pcs(line)
        case line
        when /^([A-Za-z\s\/]+) ([\d\.]+) ([\d\.,\- ]+) ([\d\.,]+)$/
          name, factor, judges, value = $1, $2, $3, $4
          @score[:components] << {
            name: name, factor: factor.to_f,
            judges: judges.tr(',', '.'), ## memo: gpjpn10 ice dance using ',' i/o '.' for decimal point
            value: value.tr(',', '.').to_f,
            number: (@score[:components].count + 1).to_i,
          }
        when /Judges Total Program Component Score/
          @mode = :deductions
        end
      end

      def parse_deductions(line)
        if line =~ /Deductions:? (.*) [0-9\.\-]+$/
          @score[:deduction_reasons] = $1
        end
      end

      ################
      protected

      def convert_pdf(url)
        return nil if url.blank?

        begin
          open(url, allow_redirections: :safe) do |f|
            tmp_filename = "score-#{rand(1000)}-tmp.pdf"
            Tempfile.create(tmp_filename) do |out|
              out.binmode
              out.write f.read

              Pdftotext.text(out.path)
            end
          end
        rescue OpenURI::HTTPError
          Rails.logger.warn("HTTP Error: #{url}")
          return nil
        end
      end
    end # module
  end
end
