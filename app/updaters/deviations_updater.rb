class DeviationsUpdater
  def initialize(verbose: false)
    @verbose = verbose
  end

  def update_deviations
    data = {}
    ElementJudgeDetail.where("officials.absence": false).joins(:element, :official).group('elements.score_id').group(:official_id).sum(:abs_deviation).each do |key, value|
      data[key] ||= {}
      data[key][:tes] = value
    end
    ComponentJudgeDetail.where("officials.absence": false).joins(:component, :official).group('components.score_id').group(:official_id).sum(:deviation).each do |key, value|
      data[key] ||= {}
      data[key][:pcs] = value
    end
    scores = Score.all.index_by(&:id)  ## TODO: use memory too much ??

    ActiveRecord::Base.transaction do
      puts 'start' if @verbose
      Deviation.delete_all    ## clear all data first
      data.each do |(score_id, official_id), hash|
        Deviation.create(
          score_id: score_id, official_id: official_id,
          tes_deviation: hash[:tes],
          pcs_deviation: hash[:pcs],
          tes_deviation_ratio: hash[:tes] / scores[score_id].elements.count,
          pcs_deviation_ratio: hash[:pcs].abs / 7.5,
        )
      end
      puts 'done.' if @verbose
    end  ## transaction
  end
end
