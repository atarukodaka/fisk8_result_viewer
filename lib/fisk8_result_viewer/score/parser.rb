module Fisk8ResultViewer
  module Score
    class Parser
      class ScoreData
        extend Forwardable
        include Enumerable

        def_delegators :@data, :each, :[], :"[]=", :"merge!", :update, :slice
        
        def initialize(attributes = {})
          @data = attributes.merge(elements: [], components: [])
        end
        def <<(hash)
          @data.update(hash)
        end
        def to_hash
          @data
        end
        def to_s
          str = "-" * 100 + "\n"
          str << "%<ranking>d %<skater_name>s [%<nation>s] %<starting_number>d  %<tss>6.2f = %<tes>6.2f + %<pcs>6.2f + %<deductions>2d\n" % self.to_hash
          str << "Executed Elements\n"
          str << self[:elements].map do |element|
            "  %<number>2d %<name>-20s %<info>-3s %<base_value>5.2f %<goe>5.2f %<judges>-30s %<value>6.2f" % element.merge(judges: element[:judges].split(/\s/).map {|v| "%4s" % [v]}.join(' '))

          end.join("\n")
          str << "\nProgram Components\n"
          str << self[:components].map do |component|
            "  %<number>d %<name>-31s %<factor>3.2f %<judges>-15s %<value>6.2f" % component
          end.join("\n")
          if self[:deduction_reasons]
            str << "\nDeductions\n  " + self[:deduction_reasons] << "\n"
          end
          str
        end ## def
      end
      ################################################################
      include Contracts
      include Fisk8ResultViewer::Utils

      SCORE_DELIMITER = /Score Score/

      Contract String => Array
      def parse_scores(score_url)
        begin
          text = convert_pdf(score_url, dir: "pdf")
        rescue OpenURI::HTTPError
          return []
        end
        text = text.force_encoding('UTF-8').gsub(/  +/, ' ').gsub(/^ */, '').gsub(/\n\n+/, "\n").chomp
        text =~ /^(.*)\n(.*) ((SHORT|FREE) (.*)) JUDGES DETAILS PER SKATER$/
        
        additional_attributes = {
          competition_name: $1,
          category: $2,
          segment: $3,
        }
        scores = []
        text.split(/\f/).map.with_index do |page_text, i|
          page_text.split(SCORE_DELIMITER)[1..-1].map do |text|
            attributes = {
              result_pdf:  "#{score_url}\#page=#{i+1}",
            }.merge(additional_attributes)
            parse_score(text, attributes: attributes)
          end
        end.flatten
      end
      def parse_score(text, attributes: {})
        @mode = :skater
        @score = ScoreData.new(attributes)

        text.split(/\n/).each do |line|
          case @mode
          when :skater
            parse_skater(line)
          when :tes
            parse_tes(line)
          when :pcs
            parse_pcs(line)
          when :deductions
            parse_deductions(line)
          end
        end  ## each line

        raise "parsing error" if @mode != :pcs && @mode != :deductions
        @score
      end
     
      protected
      def parse_skater(line)
        name_re = %q[[[:alpha:]1\.\- \/\']+]   ## adding '1' for Mariya1 BAKUSHEVA (http://www.pfsa.com.pl/results/1314/WC2013/CAT003EN.HTM)
        nation_re = %q[[A-Z][A-Z][A-Z]]
        if line =~ /^(\d+) (#{name_re}) *(#{nation_re}) (\d+) ([\d\.]+) ([\d\.]+) ([\d\.]+) ([\d\.\-]+)/
          @score << {
            ranking: $1.to_i, skater_name: $2.strip, nation: $3,
            starting_number: $4.to_i,tss: $5.to_f, tes: $6.to_f, pcs: $7.to_f,
            deductions: $8.to_f.abs * (-1),
          }
          @mode = :tes
        end
      end

      def parse_tes(line)
        case line
        when /^(\d+) +(.*)$/
          number = $1.to_i; rest = $2
          element_re = '[\w\+\!<\*]+'
          if rest =~ /(#{element_re}) ([<>\!\*e]*) *([\d\.]+) ([Xx]?) *([\d\.\-]+) ([\d\- ]+) ([\d\.\-]+)$/
            @score[:elements] << {
              number: number, name: $1, info: $2, base_value: $3.to_f,
              credit: $4.downcase, goe: $5.to_f, judges: $6, value: $7.to_f,
            }
          else
            raise "parseing error on TES"
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
            judges: judges.tr(',', '.'),      ## memo: gpjpn10 ice dance using ',' i/o '.'
            value: value.tr(',', '.').to_f,
            number: (@score[:components].size+1).to_i,
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
    end # module
  end
end
