Rails.application.routes.draw do
  ## home
  root to: 'home#index'

  resources :skaters, only: [:index, :show], param: :isu_number do
    get :list, on: :collection
  end
  
  resources :competitions, only: [:index], param: :short_name do
    get :list, on: :collection
    get '(/:category(/:segment))', action: :show, on: :member, as: ''
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

  namespace :api, format: "json" do
    resources :skaters, only: [:index, :show], param: :isu_number
    resources :competitions, only: [:index, :show], param: :short_name
    resources :scores, only: [:index, :show], param: :name
    resources :elements, only: :index
    resources :components, only: :index
  end

end
