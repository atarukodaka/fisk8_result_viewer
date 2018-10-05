namespace :parse do
  desc 'parse score of given url'
  task scores: :environment do
    url = ENV['url']
    parser = CompetitionParser::IsuGeneric::ScoreParser.new
    # rubocop:disable Metrics/LineLength
    parser.parse(url).each do |score|
      str = '-' * 100 + "\n"
      str << "%<ranking>d %<skater_name>s [%<nation>s] %<starting_number>d  %<tss>6.2f = %<tes>6.2f + %<pcs>6.2f + %<deductions>2d\n" % score
      str << "Executed Elements\n"
      str << score[:elements].map do |element|
        '  %<number>2d %<name>-20s %<info>-3s %<base_value>5.2f %<goe>5.2f %<judges>-30s %<value>6.2f' % element.merge(judges: element[:judges].split(/\s/).map { |v| '%4s' % [v] }.join(' '))
      end.join("\n")
      str << "\nProgram Components\n"
      str << score[:components].map do |component|
        '  %<number>d %<name>-31s %<factor>3.2f %<judges>-15s %<value>6.2f' % component
      end.join("\n")
      if score[:deduction_reasons]
        str << "\nDeductions\n  " + score[:deduction_reasons] << "\n"
      end
      puts str
    end
    # rubocop:enable Metrics/LineLength
  end
end
