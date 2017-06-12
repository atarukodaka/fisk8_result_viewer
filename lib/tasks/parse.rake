namespace :parse do
  desc "parse score of given url"
  task :score => :environment do
    url = ENV['url']
    parser = Fisk8ResultViewer::Score::Parser.new
    parser.parse_scores(url).each do |score|
      parser.show(score)
    end
  end
end

