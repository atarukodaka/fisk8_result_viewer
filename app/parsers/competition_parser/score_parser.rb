require 'pdftotext'
require 'tempfile'

module CompetitionParser
  class ScoreParser < ::Parser
    SCORE_DELIMITER = /Score Score/

    def normalize_line(text)
      text.force_encoding('UTF-8').gsub(/  +/, ' ').gsub(/^ */, '').gsub(/\n\n+/, "\n").chomp
    end

    def parse(score_url)
      text = convert_pdf(score_url) || (return [])
      debug("   -- parsing score: #{score_url}")
      normalize_line(text).split(/\f/).map.with_index(1) do |page_text, i|
        page_text.split(SCORE_DELIMITER)[1..-1].map do |t|
          parse_score(t) do |score|
            score[:result_pdf] = "#{score_url}\#page=#{i}"
          end
        end
      end.flatten
    end

    def parse_score(text)
      #@mode = :skater
      mode = :skater
      score = { elements: [], components: [] }

      text.split(/\n/).each do |line|
        mode = send("parse_#{mode}", line, score)
        break if mode == :done
      end
      raise 'parsing error' if still_in_progress?(mode)

      yield(score) if block_given?
      score
    end

    def still_in_progress?(mode)
      mode != :pcs && mode != :deductions  && mode != :done      
    end

    def parse_skater(line, score)
      name_re = %q([[:alpha:]1\.\- \/\']+)
      ## adding '1' for Mariya1 BAKUSHEVA
      ##   (see: http://www.pfsa.com.pl/results/1314/WC2013/CAT003EN.HTM)
      nation_re = '[A-Z][A-Z][A-Z]'
      if line =~ /^(\d+) (#{name_re}) *(#{nation_re}) (\d+) ([\d\.]+) ([\d\.]+) ([\d\.]+) ([\d\.\-]+)/
        score.update(ranking: $1.to_i, skater_name: $2.strip, nation: $3,
                     starting_number: $4.to_i, tss: $5.to_f, tes: $6.to_f,
                     pcs: $7.to_f, deductions: $8.to_f.abs * -1)
        :tes
      else
        :skater
        #@mode = :tes
      end
    end

    def parse_tes(line, score)
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
          if element[:name].match?(/<</)
            element[:downgraded] = true
          elsif element[:name].match?(/</)
            element[:underrotated] = true
          end
          score[:elements] << element
        else
          raise 'parseing error on TES'
        end
        :tes
      when /^([\d\.]+) +[\d\.]+$/
        score[:base_value] = $1.to_f
        :tes
      when /^Program Components/
        #@mode = :pcs
        :pcs
      else
        :tes
      end
    end

    def parse_pcs(line, score)
      case line
      when /^([A-Za-z\s\/]+) ([\d\.]+) ([\d\.,\- ]+) ([\d\.,]+)$/
        name, factor, judges, value = $1, $2, $3, $4
        score[:components] << {
          name: name, factor: factor.to_f,
          judges: judges.tr(',', '.'), ## memo: gpjpn10 ice dance using ',' i/o '.' for decimal point
          value: value.tr(',', '.').to_f,
          number: (score[:components].count + 1).to_i,
        }
        :pcs
      when /Judges Total Program Component Score/
        #@mode = :deductions
        :deductions
      else
        :pcs
      end
    end

    def parse_deductions(line, score)
      if line =~ /Deductions:? (.*) [0-9\.\-]+$/
        score[:deduction_reasons] = $1
        :done
      else
        :deductions
      end
    end
=begin
    def parse_done(line, score)
      ## do nothing
      :done
    end
=end
    ################
    protected

    def convert_pdf(url)
      return nil if url.blank?

      begin
        open(url, allow_redirections: :safe) do |f|            # rubocop:disable Security/Open
          Tempfile.create('score') do |out|
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
