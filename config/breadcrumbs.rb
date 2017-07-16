crumb :root do
  link "Home", root_path
end

################
crumb :skaters do
  link "Skaters", skaters_path
  parent :root
end
crumb :skater do |skater|
  link skater.name, skater_path(skater.isu_number)
  parent :skaters
end
################
# competitions
crumb :competitions do
  link "Competitions", competitions_path
  parent :root
end
crumb :competition do |competition|
  link competition.name, competition_path(competition.short_name)
  parent :competitions
end

crumb :competition_category do |competion, category|
  link competition.name, competition_path(competition.short_name)
  parent :competition
end

crumb :competition_category do |competition, category|
  link category, competition_path(competition.short_name, category: category)
  parent :competition, competition
end

crumb :competition_segment do |competition, category, segment|
  link segment, competition_path(competition.short_name, category: category, segment: segment)
  parent :competition_category, competition, category
end


################
# category results
crumb :results do
  link "Results", results_path
  parent :root
end

################
# scores
crumb :scores do
  link "scores", scores_path
  parent :root
end


crumb :score do | score|
  link [score.competition_name, score.category, score.segment, score.ranking, score.skater_name].join(' / '), scores_path
  parent :scores
end

################
crumb :elements do
  link "Elements", elements_path
  parent :root
end

crumb :components do
  link "Components", components_path
  parent :root
end

################
crumb :parsers do
  link "Parsers", parsers_path
  parent :root
end

crumb :parser_competition do
  link "Competition", nil
  parent :parsers
end
crumb :parser_score do
  link "Score", nil
  parent :parsers
end

################
crumb :statics do
  link "Statics", statics_path
  parent :root
end
