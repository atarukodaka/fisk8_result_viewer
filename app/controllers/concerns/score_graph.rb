require 'gnuplot'

class ScoreGraph
  ImageDir = File.join(Rails.public_path, "images", "score_graph")
  
  class << self
    def find_image_resource(skater, segment_type)
      glob_fname = File.join(ImageDir, "#{skater[:name].tr('/', '-')}_#{segment_type.to_s.upcase}*_*_plot.png")
      Dir.glob(glob_fname).map {|v| v.sub(/^#{Rails.public_path}/, '')}.sort {|*args|
        d = []
        args.each do |v|
          v =~ /([\d]+)\-([\d]+)\-([\d]+)_plot.png/
          d << Date.new($1, $2, $3)
        end
        d[1] <=> d[0]
      }.first
    end
    def image_filename(skater, segment, date)
      date ||= Date.new(1970, 1, 1)
      File.join(ImageDir, "%s_%s_%4d-%02d-%02d_plot.png" %
                [skater[:name].tr('/', '-'), segment,
                 date.year, date.month, date.day])
    end
  end
  def plot(skater, scores, segment)
    fname = self.class.image_filename(skater, segment, scores.pluck(:date).compact.max)
    return if File.exist?(fname)

    ys = [
          {key: :tss, color: 'rgb "orange"'},
          {key: :tes, color: 'rgb "blue"'},
          {key: :pcs, color: 'rgb "green"'},
         ] 
    Gnuplot.open do |gp|
      Gnuplot::Plot.new(gp) do |plot|
        plot.terminal "png"
        plot.output   fname
        plot.title    "#{skater[:name]} - #{segment}"
        #plot.xlabel   "x"
        plot.ylabel   "points"
        plot.grid
        plot.yrange   "[0:*]"
        plot.key      "left bottom"

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
