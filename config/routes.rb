Rails.application.routes.draw do
  ## home
  get '/' => 'home#index'
  
  ## skaters
  scope :skaters do
    get '/' => 'skaters#index'
    match ':isu_number' => 'skaters#show', via: :get
    match ':name/name' => 'skaters#show_by_name', via: :get
  end
  
  ## competitions
  scope :competitions do
    get '/' => 'competitions#index'
    match ':cid(/:category(/:segment))' => 'competitions#show', via: :get
  end

  ## scores
  scope :scores do
    get '/' => 'scores#index'
    match ':name' => 'scores#show', via: :get
    #match ':competition_cid/:category/:segment/:ranking' => 'scores#show', via: :get
  end
  ## elements
  get 'elements' => 'elements#index'
  
  ## components
  get 'components' => 'components#index'
  
  ## top
  #get '/' => 'scores#index'
end
