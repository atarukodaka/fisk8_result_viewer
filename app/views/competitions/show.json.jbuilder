json.extract! competition, :name, :cid, :competition_type, :city, :country, :site_url, :start_date, :end_date, :comment

json.category_results do
  json.set! category do
    json.array! category_results do |cr|
      json.ranking cr.ranking
      json.skater_name cr.skater.name
      json.nation cr.skater.nation
      json.points cr.points
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
        json.ranking score.ranking
        json.skater_name score.skater.name
        json.nation score.skater.nation
        json.extract! score, :starting_number, :tss, :tes, :pcs, :deductions        
        json.elements_summary score.elements.map(&:name).join(',')
        json.components_summary score.components.map(&:value).join(',')
      end
    end
  end
end

