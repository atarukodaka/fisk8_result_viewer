class DeviationsUpdater < Updater
  def update_deviations
    ActiveRecord::Base.transaction do
      Deviation.delete_all

      Score.find_each do |score|
        elements = score.elements.includes(:element_judge_details)
        officials = score.performed_segment.officials

        num_elements = score.elements.count
        num_officials = officials.count

        tes = Array.new(num_officials+1).map { Array.new(num_elements+1, {}) }
        pcs = Array.new(num_officials+1).map { Array.new(5+1, {}) }        

        ## tes
        elements.each do |element|
          details = element.element_judge_details
          avg = details.sum(:value) / details.count
          details.each do |detail|
            dev = (avg - detail.value).abs
            tes[detail.number][element.number] = {value: dev, ratio: dev/num_elements }
          end
        end

        ## pcs
        score.components.includes(:component_judge_details).each do |component|
          details = component.component_judge_details
          avg = details.sum(:value) / details.count

          details.each do |detail|
            dev = detail.value - avg
            pcs[detail.number][component.number] = { value: dev, ratio: dev/7.5 }
          end
        end

        officials.each do |official|
          Deviation.create(score: score, official: official,
                           tes_deviation: tes[official.number].sum {|hash| hash[:value].to_f },
                           tes_deviation_ratio: tes[official.number].sum {|hash| hash[:ratio].to_f },
                           pcs_deviation: pcs[official.number].sum {|hash| hash[:value].to_f },
                           pcs_deviation_ratio: pcs[official.number].sum {|hash| hash[:ratio].to_f },
                          )
        end
      end
    end
  end
end
