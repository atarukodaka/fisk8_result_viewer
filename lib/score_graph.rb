require 'gnuplot'

class ScoreGraph
  attr_reader :skater, :segment, :scores
  
  def initialize(skater, segment, scores)
    @skater, @segment, @scores = skater, segment, scores
  end
  ################
  def image_filename
    prefix = File.join(Rails.public_path, "images", "score_graph")

    date = scores.pluck(:date).compact.max
    File.join(prefix, "%s_%s_%4d-%02d-%02d_plot.png" %
              [skater[:name].tr('/', '-'), segment,
               date.year, date.month, date.day])
  end
  def image_path
    image_filename.sub(/^#{Rails.public_path}/, '')
  end
  ################
  def plot
    fname = image_filename
    return if File.exist?(fname)

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

        # draw lines
        {
          tss: { color: 'rgb "orange"'},
          tes: { color: 'rgb "blue"'},
          pcs: { color: 'rgb "green"'},
        }.each do |key, settings|
          y = scores.pluck(key).compact
          x = scores.pluck(:date).compact.map {|v|
            v.year.to_f + v.month.to_f/12 + v.day.to_f/365
          }
          plot.data << Gnuplot::DataSet.new([x, y]) do |ds|
            ds.with      = "linespoints"
            ds.linewidth = 2
            ds.linecolor = settings[:color]
            ds.title = key.to_s.upcase
          end
        end
      end
    end
    
  end
end
