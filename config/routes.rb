Rails.application.routes.draw do
  ## home
  root to: 'home#index'

  resources :skaters, only: [:index, :show], param: :isu_number do
    get :list, on: :collection
  end

  resources :competitions, only: [:index], param: :short_name do
    get :list, on: :collection
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

  resources :grandprixes, only: :index
  
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

  resources :deviations, only: [:index, :show], param: :name do
    get :list, on: :collection
    #    get :panel, on: :member, action: :show_panel # /deviations/:name/panel
    #    get :skater, on: :member, action: :show_skater # /deviations/:name/panel
  end

  resources :element_judge_details, only: :index do
    get :list, on: :collection
  end

  resources :component_judge_details, only: :index do
    get :list, on: :collection
  end
end
