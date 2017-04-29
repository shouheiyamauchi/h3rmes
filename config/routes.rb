Rails.application.routes.draw do
  resources :orders
  resources :menu_groups do
    member do
      resources :menu_items
    end
  end
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
