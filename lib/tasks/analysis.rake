namespace :analysis do

  task goediff: :environment do
    Score.all.each {|sc|
      sc.elements.each {|el|
        puts [sc.competition.season, sc.name, sc.skater.name, el.judges.split(/ /)].flatten.join(',')
      }
    }
  end

  task nhk: :environment do
    comp = Competition.last
    seg = Segment.where(segment_type: "free").first
    Score.where(competition: comp, segment: seg).each do |score|
      score.elements.each do |elem|
        puts [score.skater.name, elem.name, "'#{elem.judges}"].join(",")
      end
    end
  end

  task practice: :environment do
    Skater.all.each do |skater|
      next if skater.practice_low_season.blank?
      puts [:name, :isu_number, :nation, :practice_low_season, :practice_high_season].map {|d| skater[d]}.push(skater.category_type.name).join(',')
    end
  end

  task tech_nation: :environment do
    skater = Skater.find_by(name: 'Yuzuru HANYU')
    #skater = Skater.find_by(name: 'Shoma UNO')
    Score.where(skater: skater).joins(:competition).each do |score|
      score.performed_segment.officials.where(function_type: "technical").each do |official|
        puts "#{skater.name},#{score.competition.season},#{score.name},#{official.panel.name},#{official.panel.nation}"
      end
    end
  end

  task panel_judge: :environment do
    skater = Skater.find_by(name: "Mao ASADA")

    Element.where(element_type: :jump).where("scores.skater": skater).joins(:score).each do |element|
      success = (element.name =~ /</) ? 0 : 1
      skater_name = element.score.skater.name
      element.score.performed_segment.officials.where(function_type: :technical).each do |official|
        puts [skater_name, element.name, official.panel.name, success].join(',')
      end
    end
  end

  task asada3a: :environment do
    skater = Skater.find_by(name: "Mao ASADA")

    Element.where("scores.skater" => skater).where("elements.name like ?", "%3A%").joins(:score).each do |element|
      panels = element.score.performed_segment.officials.where(function_type: "technical").map do |official|
        official.panel.name.encode("shift_jis")
      end
      score = element.score
      puts [score.name, "'#{score.competition.season}", element.name, element.goe, panels].flatten.join(',')
    end
  end

  task components: :environment do
    men = Category.find_by(name: 'MEN')
    ladies = Category.find_by(name: 'LADIES')

    #Score.where(category: men).includes(:components).each do |score|
    Score.includes(:components).each do |score|
      puts score.components.pluck(:value).join(',')
    end
  end

  desc 'tes pcs ratio'
  task tes_pcs_ratio: :environment do
    Score.all.includes(:skater, category: [:category_type])
      .where("segments.segment_type": 'free').joins(:segment).each do |score|
      puts "#{score.category.category_type.name},#{score.name},#{score.skater.name},#{score.tes},#{score.pcs}"
    end
  end
end


__END__

require 'daru'
require 'statsample'

namespace :analysis do
  namespace :tes do
    desc 'simple stddev'
    task stddev: :environment do
      ElementJudgeDetail.where("competitions.season": '2015-16'..'2017-18').joins(element: [score: [:competition]]).pluck(:value, :average).each do |value, average|
        puts value - average
      end
    end

    task :stddev_by_judges do
      Competition.find_by(site_url: 'http://www.isuresults.com/results/season1718/owg2018/')

      ary = [:officials, [officials: [:performed_segment, performed_segment: [:scores, scores: [:skater, :competition]]]]]

      Panel.all.each do |panel|
        ary = [official: [:panel], element: [score: [:skater, :competition]]]

        a = Daru::Vector.new(ElementJudgeDetail.where("competitions.season": '2015-16'..'2017-18', "officials.panel_id": panel.id).includes(ary).references(ary).pluck(:value, :average).map { |b| b[0] - b[1] })
        puts "#{panel.name},#{panel.nation},#{a.count},#{a.mean},#{a.sd}"
      end
    end

    task :stddev_by_skater do
      comp = Competition.find_by(site_url: 'http://www.isuresults.com/results/season1718/owg2018/')
      skaters = Score.where("competitions.site_url": comp.site_url).includes(:skater).joins(:competition).map(&:skater).uniq

      skaters.each do |skater|
        ary = [element: [score: [:skater, :competition]]]

        a = Daru::Vector.new(ElementJudgeDetail.where("competitions.season": '2015-16'..'2017-18', "scores.skater_id": skater.id).includes(ary).references(ary).pluck(:value, :average).map { |b| b[0] - b[1] })
        puts "#{skater.name},#{a.count},#{a.sd}"
      end
    end

    task :max_deviation do
      ElementJudgeDetail.includes(:element, element: [:score, score: [:skater]], official: [:panel]).order(deviation: :asc).limit(100).each do |detail|
        puts "#{detail.element.score.name},#{detail.element.score.skater.name},#{detail.element.score.skater.nation},#{detail.official.panel.name},#{detail.official.panel.nation},#{detail.element.name},#{detail.value},#{detail.average}"
      end
      ElementJudgeDetail.includes(:element, element: [:score, score: [:skater]], official: [:panel]).order(deviation: :desc).limit(100).each do |detail|
        puts "#{detail.element.score.name},#{detail.element.score.skater.name},#{detail.element.score.skater.nation},#{detail.official.panel.name},#{detail.official.panel.nation},#{detail.element.name},#{detail.value},#{detail.average}"
      end
    end

    task :student_t do
      comp = Competition.find_by(site_url: 'http://www.isuresults.com/results/season1718/owg2018/')
      skaters = Score.where("competitions.site_url": comp.site_url).includes(:skater).joins(:competition).map(&:skater).uniq

      skaters.each do |skater|
        ary = [:officials, [officials: [:performed_segment, performed_segment: [:scores, scores: [:skater]]]]]
        panels = Panel.where("scores.skater_id": skater.id).includes(ary).references(ary)

        panels.each do |panel|
          ary = [:official, element: [score: [:skater, :competition]]]
          a = Daru::Vector.new(ElementJudgeDetail.includes(ary).where("competitions.season": '2015-16'..'2017-18', "officials.panel_id": panel.id, "scores.skater_id": skater.id).references(ary).pluck(:value, :average).map { |b| b[0] - b[1] })
          b = Daru::Vector.new(ElementJudgeDetail.includes(ary).where.not("officials.panel": panel).where("competitions.season": '2015-16'..'2017-18', "scores.skater_Id": skater.id).references(ary).pluck(:value, :average).map { |c| c[0] - c[1] })
          next unless !a.nil? && !b.nil?

          begin
            t2 = Statsample::Test::T::TwoSamplesIndependent.new(a, b)
            puts [skater.name, skater.nation, panel.name, panel.nation, t2.t_not_equal_variance, t2.probability_not_equal_variance, a.count, b.count].join(', ')
          rescue StandardError
            puts 'some errors on test-t'
          end
        end
      end
    end
  end ## tes

  ################
  namespace :pcs do
    task stddev: :environment do
      ComponentJudgeDetail.where("competitions.season": '2015-16'..'2017-18').joins(component: [score: [:competition]]).pluck(:value, :average).each do |value, average|
        puts STDOUT value - average
      end
    end

    task :max_deviation do
      ComponentJudgeDetail.includes(:component, component: [:score, score: [:skater]], official: [:panel]).order(deviation: :asc).limit(100).each do |detail|
        puts "#{detail.component.score.name},#{detail.component.score.skater.name},#{detail.component.score.skater.nation},#{detail.official.panel.name},#{detail.official.panel.nation},#{detail.component.name},#{detail.value},#{detail.average}"
      end
      ComponentJudgeDetail.includes(:component, component: [:score, score: [:skater]], official: [:panel]).order(deviation: :desc).limit(100).each do |detail|
        puts "#{detail.component.score.name},#{detail.component.score.skater.name},#{detail.component.score.skater.nation},#{detail.official.panel.name},#{detail.official.panel.nation},#{detail.component.name},#{detail.value},#{detail.average}"
      end
    end

    task :student_t do
      comp = Competition.find_by(site_url: 'http://www.isuresults.com/results/season1718/owg2018/')
      skaters = Score.where("competitions.site_url": comp.site_url).includes(:skater).joins(:competition).map(&:skater).uniq

      skaters.each do |skater|
        ary = [:officials, [officials: [:performed_segment, performed_segment: [:scores, scores: [:skater]]]]]
        panels = Panel.where("scores.skater_id": skater.id).includes(ary).references(ary)

        panels.each do |panel|
          ary = [:official, component: [score: [:skater, :competition]]]
          a = Daru::Vector.new(ComponentJudgeDetail.includes(ary)
                                .where("competitions.season": '2015-16'..'2017-18', "officials.panel_id": panel.id, "scores.skater_id": skater.id).references(ary).pluck(:value, :average).map { |b| b[0] - b[1] })
          b = Daru::Vector.new(ComponentJudgeDetail.includes(ary)
                                .where.not("officials.panel": panel)
                                .where("competitions.season": '2015-16'..'2017-18', "scores.skater_Id": skater.id).references(ary).pluck(:value, :average).map { |c| c[0] - c[1] })
          next unless !a.nil? && !b.nil?

          begin
            t2 = Statsample::Test::T::TwoSamplesIndependent.new(a, b)
            puts [skater.name, skater.nation, panel.name, panel.nation, t2.t_not_equal_variance, t2.probability_not_equal_variance, a.count, b.count].join(', ')
          rescue StandardError
          end
        end
      end
    end
  end ## pcs
end
