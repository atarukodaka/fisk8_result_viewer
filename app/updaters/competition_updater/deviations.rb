module CompetitionUpdater::Deviations
  def update_deviations(score)
    ActiveRecord::Base.transaction do
      tes = calculate_tes_deviations(score.elements)
      pcs = calculate_pcs_deviations(score.components)

      score.performed_segment.officials.each do |official|
        create_deviation(score, official, tes, pcs)
      end
    end  ## transaction
  end

  protected

  def create_deviation(score, official, tes, pcs)
    official_number = official.number

    score.deviations.create(official: official,
                            # tes_deviation: tes[official_number].sum { |_k, hash| hash[:value].to_f },
                            # tes_deviation_ratio: tes[official_number].sum { |_k, hash| hash[:ratio].to_f },
                            # pcs_deviation: pcs[official_number].sum { |_k, hash| hash[:value].to_f },
                            # pcs_deviation_ratio: pcs[official_number].sum { |_k, hash| hash[:ratio].to_f })
                            tes_deviation: tes[official_number].values.sum { |hash| hash[:value].to_f },
                            tes_deviation_ratio: tes[official_number].values.sum { |hash| hash[:ratio].to_f },
                            pcs_deviation: pcs[official_number].values.sum { |hash| hash[:value].to_f },
                            pcs_deviation_ratio: pcs[official_number].values.sum { |hash| hash[:ratio].to_f })
  end

  def calculate_tes_deviations(elements)
    num_elements = elements.count

    tes = Hash.new { |h, k| h[k] = {} }
    elements.includes(:element_judge_details).each do |element|
      element_number = element.number
      values = element.element_judge_details.pluck(:value, :number)
      avg = values.sum { |d| d[0] } / values.size
      values.each do |value, i|
        dev = (avg - value).abs
        tes[i][element_number] = { value: dev, ratio: dev / num_elements }
      end
    end
    tes
  end

  def calculate_pcs_deviations(components)
    pcs = Hash.new { |h, k| h[k] = {} }
    components.includes(:component_judge_details).each do |component|
      component_number = component.number
      values = component.component_judge_details.joins(:official).pluck(:value, :number)
      avg = values.sum { |d| d[0] } / values.size
      values.each do |value, i|
        dev = value - avg
        pcs[i][component_number] = { value: dev, ratio: dev / 7.5 }
      end
    end
    pcs
  end
end
