crumb :root do
  link t('controller.home', default: 'Home'), root_path
end

################
crumb :skaters do
  link t('controller.skaters', default: 'Skaters'), skaters_path
  parent :root
end
crumb :skater do |skater|
  link skater.name, skater_path(skater.isu_number)
  parent :skaters
end
################
# competitions
crumb :competitions do
  link t('controller.competitions', default: 'Competitions'), competitions_path
  parent :root
end
crumb :competition do |competition|
  link competition.name, competition_path(competition.key)
  parent :competitions
end

crumb :competition_category do |_competion, _category|
  link competition.name, competition_path(competition.key)
  parent :competition
end

crumb :competition_category do |competition, category|
  link category.name, competition_path(competition.key, category: category.name)
  parent :competition, competition
end

crumb :competition_segment do |competition, category, segment|
  link segment.name, competition_path(competition.key, category: category.name, segment: segment.name)
  parent :competition_category, competition, category
end

################
# category results
=begin
crumb :results do
  link "Results", results_path
  parent :root
end
=end

################
# scores
crumb :scores do
  link t('controller.scores', default: 'scores'), scores_path
  parent :root
end

crumb :score do |score|
  link [score.competition_name, score.category.name, score.segment.name,
        score.ranking, score.skater_name].join(' / '), scores_path
  parent :scores
end

################
crumb :elements do
  link t('controller.elements', default: 'Elements'), elements_path
  parent :root
end

crumb :components do
  link 'Components', components_path
  parent :root
end

################
crumb :parsers do
  link 'Parsers', parsers_path
  parent :root
end

crumb :parser_competition do
  link 'Competition', nil
  parent :parsers
end
crumb :parser_score do
  link 'Score', nil
  parent :parsers
end

################
crumb :statics do
  link 'Statics', statics_path
  parent :root
end

################
crumb :panels do
  link 'Panels', panels_path
  parent :root
end

crumb :panel do |panel|
  link panel.name
  parent :panels
end

crumb :element_judge_details do
  link 'Element Judge Details', element_judge_details_path
  parent :root
end

crumb :component_judge_details do
  link 'Component Judge Details', component_judge_details_path
  parent :root
end

crumb :deviations do |_deviation|
  link 'Deviations', deviations_path
  parent :root
end

crumb :panel_deviation do |panel_name|
  link "Panel  / #{panel_name}", deviations_path
  parent :deviations
end

crumb :skater_deviation do |skater_name|
  link "Skater  / #{skater_name}", deviations_path
  parent :deviations
end
