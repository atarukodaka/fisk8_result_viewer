class DeviationsUpdater < Updater
  def create_deviation(score, official, tes, pcs)
    official_number = official.number

    Deviation.create(score: score, official: official,
                     tes_deviation: tes[official_number].sum { |_k, hash| hash[:value].to_f },
                     tes_deviation_ratio: tes[official_number].sum { |_k, hash| hash[:ratio].to_f },
                     pcs_deviation: pcs[official_number].sum { |_k, hash| hash[:value].to_f },
                     pcs_deviation_ratio: pcs[official_number].sum { |_k, hash| hash[:ratio].to_f })
  end

  def calculate_tes_deviations(elements)
    num_elements = elements.count

    data = Hash.new { |h, k| h[k] = {} }
    elements.includes(:element_judge_details).each do |element|
      details = element.element_judge_details
      avg = details.sum(:value) / details.count
      details.each do |detail|
        dev = (avg - detail.value).abs
        data[detail.number][element.number] = { value: dev, ratio: dev / num_elements }
      end
    end
    data
  end

  def calculate_pcs_deviations(components)
    data = Hash.new { |h, k| h[k] = {} }
    components.includes(:component_judge_details).each do |component|
      details = component.component_judge_details
      avg = details.sum(:value) / details.count

      details.each do |detail|
        dev = detail.value - avg
        data[detail.number][component.number] = { value: dev, ratio: dev / 7.5 }
      end
    end
    data
  end

  def update_deviations
    ActiveRecord::Base.transaction do
      Deviation.delete_all

      Score.find_each do |score|
        tes = calculate_tes_deviations(score.elements)
        pcs = calculate_pcs_deviations(score.components)

        score.performed_segment.officials.each do |official|
          create_deviation(score, official, tes, pcs)
        end
      end
    end
  end
end
