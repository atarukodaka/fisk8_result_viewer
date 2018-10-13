module CompetitionUpdater::Scores
  def update_score(competition, category, segment, attributes: {})
    relevant_cr = nil
    ActiveRecord::Base.transaction do
      sc = competition.scores.create!(category: category, segment: segment) { |score|
        relevant_cr = competition.category_results
                      .where(category: category, "#{segment.segment_type}_ranking": attributes[:ranking]).first
        skater = relevant_cr.try(:skater) ||
                 find_or_create_skater(attributes[:isu_number], attributes[:skater_name], attributes[:nation], category)
        ps = competition.performed_segments
             .where(category: category, segment: segment).first || raise('no relevant Performed Segment')

        score.attributes = slice_common_attributes(score, attributes)
                           .merge(skater: skater, date: ps.starting_time.to_date)
      }
      relevant_cr.present? && relevant_cr.update(segment.segment_type => sc)
      sc            ## ensure to return score object
    end
  end

  ################
  def update_scores(competition, category, segment, score_url)
    parser(:score).parse(score_url).each do |attrs|
      ActiveRecord::Base.transaction do
        score = competition.scores
                .where(category: category, segment: segment, starting_number: attrs[:starting_number]).first ||
                begin
                  detail = "#{category.name}/#{segment.name}##{attrs[:starting_number]}"
                  debug("no relevant score found: #{detail}", indent: 10)
                  update_score(competition, category, segment, attributes: attrs)
                end

        score.attributes = slice_common_attributes(score, attrs)

        attrs[:elements].map { |item| score.elements.create!(item) }
        attrs[:components].map { |item| score.components.create!(item) }

        score.update(elements_summary: score.elements.map(&:name).join('/'))
        score.update(components_summary: score.components.map(&:value).join('/'))
        debug(score.summary)
      end
    end
  end ## def

  ################
  def update_judge_details(score)
    officials = score.performed_segment.officials.map { |d| [d.number, d] }.to_h

    score.elements.each do |element|
      element.judges.split(/\s/).map(&:to_f).each.with_index(1) do |value, i|
        element.element_judge_details.create(number: i, value: value, official: officials[i])
      end
    end
    score.components.each do |component|
      component.judges.split(/\s/).map(&:to_f).each.with_index(1) do |value, i|
        component.component_judge_details.create(number: i, value: value, official: officials[i])
      end
    end
  end
end
