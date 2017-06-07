json.extract! competition, :name, :cid, :competition_type, :city, :country, :site_url, :start_date, :end_date, :comment

json.category_results do
  json.set! category do
    json.array! category_results do |cr|
      json.extract! cr, :ranking, :skater_name, :nation, :points #, :short_tss, :free_ranking, :free_tss
      json.short_ranking cr.short_ranking
      json.short_tss cr.scores.first.try(:tss)
      json.free_ranking cr.free_ranking
      json.free_tss cr.scores.second.try(:tss)
    end
  end
end

json.segment_scores do
  json.set! category do
    json.set! segment do
      json.array! segment_scores do |score|
        json.extract! score, :ranking, :skater_name, :nation, :starting_number, :tss, :tes, :pcs, :deductions
        json.elements_summary score.elements.map(&:name).join(',')
        json.components_summary score.components.map(&:value).join(',')
      end
    end
  end
end

