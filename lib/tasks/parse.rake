namespace :parse do
  desc "parse score of given url"
  task :scores => :environment do
    url = ENV['url']
    parser = Fisk8ResultViewer::Score::Parser.new
    parser.parse_scores(url).each do |score|
      puts score.to_s
    end
  end
end

