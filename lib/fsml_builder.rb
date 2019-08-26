module FsmlBuilder
  def build_competition(competition, doc: nil)
    doc ||= Nokogiri::XML::Document.new

    Nokogiri::XML::Builder.with(doc) do |xml|
      xml.competition(name: competition.name) {
        xml.site_url { xml.text competition.site_url }
        xml.location {
          xml.city { xml.text competition.city }
          xml.country { xml.text competition.country }
        }
        xml.time_schedule {
          competition.time_schedules.includes(:category, :segment).each do |item|
            xml.starting_time(category: item.category.name, segment: item.segment.name){
              xml.text item.starting_time
            }
          end
        }
        xml.results {
          competition.category_results.includes(:category, :skater).each do |result|
            xml.result(result.slice(:ranking, :points, :short_ranking, :free_ranking).merge(category: result.category.name)) {
              xml.skater(isu_number: result.skater.isu_number, nation: result.skater.nation){
                xml.text result.skater.name
              }
            }
          end
        }

        xml.scores {
          competition.scores.includes(:category, :segment, :skater).each do |score|
            xml.score(competition: score.competition.name, category: score.category.name, segment: score.segment.name) {
              xml.skater(isu_number: score.skater.isu_number, nation: score.skater.nation) {
                xml.text score.skater.name
              }

              xml.ranking { xml.text score.ranking }
              xml.tss { xml.text score.tss }
              xml.tes { xml.text score.tes }
              xml.pcs { xml.text score.pcs }
              xml.deductions { xml.text score.deductions }

              xml.elements {
                score.elements.each.with_index(1) do |element, i|
                  xml.element(element.slice(:name, :base_value, :info, :credit).merge(number: i, judge_details: element[:judges]).compact){
                    xml.text element.value
                  }
                end
              }
              xml.components {
                score.components.each.with_index(1) do |component, i|
                  xml.component(component.slice(:name, :factor).merge(number: i, judge_details: component[:judges]).compact) {
                    xml.text component.value
                  }
                end
              }
            }
          end
        }
      }
    end
    doc
  end
  def build_score(score, doc: nil)
    doc ||= Nokogiri::XML::Document.new

    Nokogiri::XML::Builder.with(doc) do |xml|
      xml.score(competition: score.competition.name, category: score.category.name, segment: score.segment.name) {
        xml.skater(isu_number: score.skater.isu_number, nation: score.skater.nation) {
          xml.text score.skater.name
        }

        xml.ranking { xml.text score.ranking }
        xml.tss { xml.text score.tss }
        xml.tes { xml.text score.tes }
        xml.pcs { xml.text score.pcs }
        xml.deductions { xml.text score.deductions }

        xml.elements {
          score.elements.each.with_index(1) do |element, i|
            xml.element(element.slice(:name, :base_value, :info, :credit).merge(number: i, judge_details: element[:judges]).compact){
              xml.text element.value
            }
          end
        }
        xml.components {
          score.components.each.with_index(1) do |component, i|
            xml.component(component.slice(:name, :factor).merge(number: i, judge_details: component[:judges]).compact) {
              xml.text component.value
            }
          end
        }
      }
    end
    doc
  end

  module_function :build_score, :build_competition
end
