Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :menus do
        resources :menu_items, only: [:index, :create]
      end
      resources :menu_items, except: [:index, :create]
    end
  end
end
