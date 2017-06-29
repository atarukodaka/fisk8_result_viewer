Rails.application.routes.draw do
  ## home
  root to: 'home#index'
  
  ## skaters
  get '/skaters' => 'skaters#index'
  get '/skaters/:isu_number' => 'skaters#show', as: :skater
  #get '/skaters/:name/name' => 'skaters#show_by_name', as: :skater_name

  ## competitions
  get '/competitions' => 'competitions#index'
  get '/competitions/:short_name(/:category(/:segment))' => 'competitions#show', as: :competition

  ## scores##
  get '/scores' => 'scores#index'
  get '/scores/:name' => 'scores#show', as: :score

  ## elements
  get 'elements' => 'elements#index'
  
  ## components
  get 'components' => 'components#index'
  
  ## top
  #get '/' => 'scores#index'
end
