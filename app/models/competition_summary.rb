class CompetitionSummary < ActiveHash::Base
  fields :site_url, :name, :city, :country
  fields :result_summary, :time_schedule

  def start_date
    time_schedule.map {|e| e[:time]}.min
  end
  def end_date
    time_schedule.map {|e| e[:time]}.max
  end

  def season
    year, month = start_date.year, start_date.month
    year -= 1 if month <= 6
    "%04d-%02d" % [year, (year+1) % 100]
  end
  def categories
    result_summary.map {|h| h[:category]}.sort.uniq
  end
  def segments(category)
    result_summary.select {|h| h[:category] == category && h[:segment].present?}.map {|h| h[:segment]}.uniq
  end
  def result_url(category, segment=nil)
    if segment.nil?
      find_row(:result_summary, category, "").try(:[], :result_url)
    else
      find_row(:result_summary, category, segment).try(:[], :result_url)
    end
  end
  def score_url(category, segment)
    find_row(:result_summary, category, segment).try(:[], :score_url)
  end
  def starting_time(category, segment)
    find_row(:time_schedule, category, segment).try(:[], :time)
  end
=begin
  def method_missing(name, *args)
    @data.send(name, *args)
  end
=end
  ################
  private
  def find_row(key, category, segment)
    self[key].select {|h|
      h[:category] == category && h[:segment] == segment
    }.first
    
  end
end
