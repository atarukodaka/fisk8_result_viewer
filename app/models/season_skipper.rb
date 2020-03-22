class SeasonSkipper
  include DebugPrint

  def initialize(specific_season, from: nil, to: nil)
    @from = specific_season || from
    @to = specific_season || to
  end

  def skip?(season)
    season = SkateSeason.new(season) unless season.class == SkateSeason

    if (@from.nil? && @to.nil?) || season.between?(@from, @to)
      false
    else
      debug('skipping...season %s out of range [%s, %s]' % [season, @from, @to], indent: 3)
      true
    end
  end
end
