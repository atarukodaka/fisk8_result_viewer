module Fisk8ResultViewer
  module Score
    class Parser
      include Utils
      include Contracts
      
      SCORE_DELIMITER = /Score Score/

      Contract String, Hash, Symbol => Symbol
      def parse_skater(line, score, mode)
        name_re = %q[[[:alpha:]1\.\- \/\']+]   ## 1 for Mariya1 BAKUSHEVA
        if line =~ /^(\d+) (#{name_re}) *([A-Z][A-Z][A-Z]) (\d+) ([\d\.]+) ([\d\.]+) ([\d\.]+) ([\d\.\-]+)/
          hash = {
                ranking: $1.to_i, skater_name: $2, nation: $3, starting_number: $4.to_i,
            tss: $5.to_f, tes: $6.to_f, pcs: $7.to_f, deductions: $8.to_f.abs * (-1),
          }
          
          hash[:skater_name] = hash[:skater_name].to_s.strip.gsub(/ *$/, '')
          score.merge!(hash)
          mode = :tes
        end
        mode
      end
      Contract String, Hash, Symbol => Symbol      
      def parse_tes(line, score, mode)
        element_re = '[\w\+\!<\*]+'
        if line =~ /^(\d+) +(.*)$/
          number = $1.to_i; rest = $2
          if rest =~ /(#{element_re}) ([<>\!\*e]*) *([\d\.]+) ([Xx]?) *([\d\.\-]+) ([\d\- ]+) ([\d\.\-]+)$/
            score[:elements] << {
              number: number, name: $1, info: $2, base_value: $3.to_f,
              credit: $4.downcase, goe: $5.to_f, judges: $6, value: $7.to_f,
            }
          else
            logger.warn "  !! SOMETHING WRONG ON PARSING TES !! #{line}"
          end
        elsif line =~ /^([\d\.]+) +[\d\.]+$/
          score[:base_value] = $1.to_f
        elsif line =~ /^Program Components/
          mode = :pcs
        end
        mode
      end
      Contract String, Hash, Symbol => Symbol
      def parse_pcs(line, score, mode)
        ## memo: gpjpn10 ice dance using ',' i/o '.'
        if line =~ /^([A-Za-z\s\/]+) ([\d\.]+) ([\d\.,\- ]+) ([\d\.,]+)$/
          name, factor, judges, value = $1, $2, $3, $4
          score[:components] << {
            name: name, factor: factor.to_f,
            judges: judges.tr(',', '.'),
            value: value.tr(',', '.').to_f,
            number: (score[:components].size+1).to_i,
          }
        elsif line =~ /Judges Total Program Component Score/
          mode = :deductions
        end
        mode
      end
      Contract String, Hash, Symbol => Symbol
      def parse_deductions(line, score, mode)
        if line =~ /Deductions:? (.*) [0-9\.\-]+$/
          score[:deduction_reasons] = $1
        end
        mode
      end
      Contract String => Hash
      def parse_each_score(text)
        mode = :skater
        score = { elements: [], components: [],}

        text.split(/\n/).each do |line|
          case mode
          when :skater
            mode = parse_skater(line, score, mode)
          when :tes
            mode = parse_tes(line, score, mode)
          when :pcs
            mode = parse_pcs(line, score, mode)
          when :deductions
            mode = parse_deductions(line, score, mode)
          end
        end  ## each line
        score
      end
      Contract String => Array
      def parse_scores(score_url)
        begin
          text = convert_pdf(score_url, dir: "pdf")
        rescue OpenURI::HTTPError
          return []
        end
        text = text.force_encoding('UTF-8').gsub(/  +/, ' ').gsub(/^ */, '').gsub(/\n\n+/, "\n").chomp

        text =~ /^(.*)\n(.*) ((SHORT|FREE) (.*)) JUDGES DETAILS PER SKATER$/
        
        additional_entries = {
          competition_name: $1,
          category: $2,
          segment: $3,
        }
        scores = []
        text.split(/\f/).each_with_index do |page_text, i|
          page_text.split(SCORE_DELIMITER)[1..-1].each do |t|          
            result_pdf =  "#{score_url}\#page=#{i+1}"
            score = parse_each_score(t)  # , additional_entries: additional_entries)
            scores << score.merge(additional_entries).merge(result_pdf: result_pdf)
          end
        end
        return scores
      end  # def parser
      
      def show(score)
        puts "-" * 100
        puts "%d %s [%s] %d  %6.2f = %6.2f + %6.2f + %2d" % 
          [score[:ranking], score[:skater_name], score[:nation], score[:starting_number],
           score[:tss], score[:tes], score[:pcs], score[:deductions],
          ]
        puts "Executed Elements"
        score[:elements].each do |element|
          puts "  %2d %-20s %-3s %5.2f %5.2f %-30s %6.2f" %
            [element[:number], element[:name], element[:info], element[:base_value],
             element[:goe], element[:judges].split(/\s/).map {|v| "%4s" % [v]}.join(' '),
             element[:value]]
        end
        puts "Program Components"
        score[:components].each do |component|
          puts "  %d %-31s %3.2f %-15s %6.2f" %
            [component[:number], component[:name], component[:factor],
             component[:judges], component[:value]]
        end
        if score[:deduction_reasons]
          puts "Deductions"
          puts "  " + score[:deduction_reasons]
        end
      end
    end # module
  end
end
