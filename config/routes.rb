Rails.application.routes.draw do
  ## home
  root to: 'home#index'

  namespace :skaters do
    get '', action: :index
    get :list
    get ':isu_number', action: :show
  end

  namespace :competitions do
    get :index
    get :list
    get ':short_name(/:category(/:segment))', action: :show
  end

  namespace :scores do
    get :index
    get :list
    get :name, action: :show
  end
  
  namespace :elements do
    get :index
    get :list
  end

  namespace :components do
    get :index
    get :list
  end

  namespace :parsers do
    get :index
    get :competitions
    get :scores
  end

  namespace :api do
    namespace :skaters do
      get '', action: :index
    end
  end
end
