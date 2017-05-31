require 'gnuplot'

class ScoreGraph
  PublicDir = "public"
  ImageDir = File.join(PublicDir, "images", "score_graph")
  
  class << self
    def find_image_resource(skater, segment_type, prefix: "")
      Dir.glob(File.join(ImageDir, "#{skater.name}_#{segment_type.to_s}_*_plot.png")).map {|v| v.sub(/^#{PublicDir}/, '')}.sort {|*args|
        d = []
        args.each do |v|
          v =~ /([\d]+)\-([\d]+)\-([\d]+)_plot.png/
          d = Date.new($1, $2, $3)
        end
        d[1] <=> d[0]
      }.first
      
      #File.join(prefix, "images", "#{skater.name}_#{segment_type.to_s}_plot.png")
    end
    def image_filename(skater, segment_type, date)
      #image_source(skater, segment_type, prefix: "public")
      File.join(ImageDir, "%s_%s_%4d-%02d-%02d_plot.png" %
                [skater.name, segment_type.to_s,
                 date.year, date.month, date.day])
    end
  end
  def plot(skater, scores, segment_type)
    fname = self.class.image_filename(skater, segment_type, scores.pluck(:date).compact.max)
    return if File.exists?(fname)
      
    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        plot.terminal "png"
        plot.output   fname
        plot.title    "#{skater.name} - #{segment_type.to_s}"
        #plot.xlabel   "x"
        plot.ylabel   "points"
        plot.grid
        plot.yrange   "[0:*]"
        plot.key      "left bottom"

        ys = [{key: :tss, color: 'rgb "orange"'}, {key: :tes, color: 'rgb "blue"'},{key: :pcs, color: 'rgb "green"'},]

        ys.each do |hash|
          y = scores.pluck(hash[:key]).compact # .reject {|v| v == 0 }
          x = scores.pluck(:date).compact.map {|v| v.year.to_f + v.month.to_f/12 + v.day.to_f/365 }
          plot.data << Gnuplot::DataSet.new([x, y]) do |ds|
            ds.with      = "linespoints"
            ds.linewidth = 2
            ds.linecolor = hash[:color]
            ds.title = hash[:key].to_s.upcase
          end
        end
      end
    end
    
  end
end
