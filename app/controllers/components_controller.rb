class ComponentsListDecorator < ListDecorator
  def sid
    h.link_to_score(model.sid, model.sid)
  end
end
################################################################
class ComponentsController <  ApplicationController
  def filters
    @_filters ||= IndexFilters.new.tap do |f|
      f.filters = {
        value: {operator: :compare, input: :text_field, model: Component},
      }.merge score_filters.filters
    end
  end
  def display_keys
#    [:sid, :competition_name, :category, :segment, :date, :season,
    [:sid, :competition_name, :date, :season,
    :ranking, :skater_name, :nation,
     :number, :component, :factor, :judges, :value]
  end

  def collection
    Component.with_score.order("scores.date desc").joins(score: [:competition]).filter(filters.create_arel_tables(params)).select("scores.*, competitions.season, components.*")
  end
end
