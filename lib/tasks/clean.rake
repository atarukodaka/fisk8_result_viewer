namespace 'clean' do
  desc 'clear score graphs'
  task :score_graphs => :environment do
    FileUtils.rm(Dir.glob(File.join(ScoreGraph::ImageDir, "*_plot.png")))
  end
end
