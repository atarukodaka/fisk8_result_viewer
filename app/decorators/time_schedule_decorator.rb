class TimeScheduleDecorator < EntryDecorator
  def category_name
    h.link_to_competition(model.competition, category: model.category)
  end

  def segment_name
    h.link_to_competition(model.competition, category: model.category, segment: model.segment)
  end

  def starting_time
    l(model.starting_time.in_time_zone(model.competition.timezone))
  end
end
