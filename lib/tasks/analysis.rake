namespace :analysis do
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
