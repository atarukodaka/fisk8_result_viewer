## stddev by skater
if false
  comp = Competition.find_by(site_url: "http://www.isuresults.com/results/season1718/owg2018/")
  skaters = Score.where("competitions.site_url": comp.site_url).includes(:skater).joins(:competition).map {|score| score.skater}.uniq

  skaters.each do |skater|
    ary = [element: [ score: [:skater, :competition]]]
    
    a = Daru::Vector.new(ElementJudgeDetail.where("competitions.season":  "2015-16".."2017-18", "scores.skater_id": skater.id).includes(ary).references(ary).pluck(:value, :average).map {|a| a[0]-a[1]})
    puts "#{skater.name},#{a.count},#{a.sd}"
  end
end

## stddev by judges
if true
  comp = Competition.find_by(site_url: "http://www.isuresults.com/results/season1718/owg2018/")

  ary = [:officials, [officials: [:performed_segment, performed_segment: [:scores, scores: [:skater, :competition]]]]]

  Panel.all.each do |panel|
    ary = [official: [ :panel], element: [ score: [:skater, :competition]]]
    
    a = Daru::Vector.new(ElementJudgeDetail.where("competitions.season":  "2015-16".."2017-18", "officials.panel_id": panel.id).includes(ary).references(ary).pluck(:value, :average).map {|a| a[0]-a[1]})
    puts "#{panel.name},#{panel.nation},#{a.count},#{a.mean},#{a.sd}"
  end
end


if false
  ElementJudgeDetail.where("competitions.season":  "2015-16".."2017-18").joins(element: [ score: [ :competition]]).pluck(:value, :average).each do |value, average|
    puts value - average
  end
end

if false
  comp = Competition.find_by(site_url: "http://www.isuresults.com/results/season1718/owg2018/")
  skaters = Score.where("competitions.site_url": comp.site_url).includes(:skater).joins(:competition).map {|score| score.skater}.uniq

  skaters.each do |skater|
    ary = [:officials, [officials: [:performed_segment, performed_segment: [:scores, scores: [:skater]]]]]
    panels = Panel.where("scores.skater_id": skater.id).includes(ary).references(ary)

    panels.each do |panel|
      ary = [:official, element: [score: [:skater, :competition]]]
      a = Daru::Vector.new(ElementJudgeDetail.includes(ary).where("competitions.season": "2015-16".."2017-18", "officials.panel_id": panel.id, "scores.skater_id": skater.id).references(ary).pluck(:value, :average).map {|a| a[0]-a[1]})
      b = Daru::Vector.new(ElementJudgeDetail.includes(ary).where.not("officials.panel": panel).where("competitions.season": "2015-16".."2017-18", "scores.skater_Id": skater.id).references(ary).pluck(:value, :average).map {|a| a[0]-a[1]}) 
      if (!a.nil?) && (!b.nil?)
        begin
          t2 =  Statsample::Test::T::TwoSamplesIndependent.new(a, b)
          puts [skater.name, skater.nation, panel.name, panel.nation, t2.t_not_equal_variance, t2.probability_not_equal_variance, a.count,b.count].join(', ')
        rescue
        end
      end
    end
  end
end

  
