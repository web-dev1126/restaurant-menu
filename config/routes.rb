Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :restaurants do
        resources :menus, only: [:index, :create]
      end
      resources :menus, except: [:index, :create] do
        resources :menu_items, only: [:index, :create]
      end
      resources :menu_items, except: [:index, :create]
      resources :restaurants, only: [:index, :show, :create, :update, :destroy]
      post 'import', to: 'imports#create'
    end
  end

  get "health", to: "health#show"
  root "health#show"
end
