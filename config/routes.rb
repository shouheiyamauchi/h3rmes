Rails.application.routes.draw do
  resources :orders
  resources :menu_items
  resources :menu_groups
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
