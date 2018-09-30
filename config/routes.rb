Rails.application.routes.draw do
  ## home
  root to: 'home#index'

  resources :skaters, only: [:index, :show], param: :isu_number do
    get :list, on: :collection
  end
  
  resources :competitions, only: [:index], param: :short_name do
    get :list, on: :collection
    #get '(/:category(/:segment))', action: :show, on: :member, as: ''
    get '(/:category(/:segment(/:ranking)))', action: :show, on: :member, as: ''
  end

  resources :results, only: [:index], param: :name do
    get :list, on: :collection
  end
  
  resources :scores, only: [:index, :show], param: :name do
    get :list, on: :collection
  end

  resources :elements, only: :index do
    get :list, on: :collection
  end

  resources :components, only: :index do
    get :list, on: :collection
  end

  resources :parsers, only: :index do
    collection do
      get :competition
      get :scores
    end
  end

  resources :statics, only: :index

  resources :panels, only: [:index, :show], param: :name do
    get :list, on: :collection
  end

  #resources :deviations, only: [:index, :show], param: :panel_name do
  resources :deviations, only: [:index, :show], param: :name do
    get :list, on: :collection
    get :panel, on: :member    # /deviations/:name/panel
    get :skater, on: :member    # /deviations/:name/panel    
  end
  #get '/deviations/panel/:name', controller: :deviations, action: :show_panel, as: :deviations_panel
  #get '/deviations/skater/:name', controller: :deviations, action: :show_skater, as: :deviations_skater

  resources :element_judge_details, only: :index do # [:index, :show] do # , param: :score_name do
    get :list, on: :collection
    #get '(/:element_number)', action: :show, on: :member, as: ''
  end
  
  resources :component_judge_details, only: :index do # [:index, :show], param: :name do
    get :list, on: :collection
    #get '(/:number)', action: :show, on: :member, as: ''
  end

  ################
  namespace :api, format: "json" do
    resources :skaters, only: [:index, :show], param: :isu_number
    resources :competitions, only: [:index, :show], param: :short_name
    resources :results, only: :index
    resources :scores, only: [:index, :show], param: :name
    resources :elements, only: :index
    resources :components, only: :index
  end

end
