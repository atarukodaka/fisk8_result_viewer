Rails.application.routes.draw do
  ## home
  root to: 'home#index'
  
  ## skaters
  get '/skaters' => 'skaters#index'
  get '/skaters/list' => 'skaters#list'
  get '/skaters/update_skaters' => 'skaters#update_skaters'
  get '/skaters/:isu_number' => 'skaters#show', as: :skater
  #get '/skaters/:name/name' => 'skaters#show_by_name', as: :skater_name

  ## competitions
  get '/competitions' => 'competitions#index'
  get '/competitions/list' => 'competitions#list'
  get '/competitions/show_competition' => 'competitions#show_competition'
  
  get '/competitions/:short_name(/:category(/:segment))' => 'competitions#show', as: :competition

  ## scores##
  get '/scores' => 'scores#index'
  get '/scores/list' => 'scores#list'
  get '/scores/show_scores' => 'scores#show_scores'
  get '/scores/:name' => 'scores#show', as: :score

  ## elements
  get 'elements' => 'elements#index'
  get '/elements/list' => 'elements#list'
  
  ## components
  get 'components' => 'components#index'
  get '/components/list' => 'components#list'
end
