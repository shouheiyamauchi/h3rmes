Rails.application.routes.draw do
  root 'pages#home'

  get 'pages/json'
  post 'pages/create_order'
  post 'pages/main_menu'
  post 'pages/list_foods'
  post 'pages/list_categories'
  post 'pages/add_item'
  post 'pages/find_total'
  post 'pages/make_payment'
  resources :orders

  devise_for :users, controllers: { registrations: 'users/registrations' }

  resources :menu_groups do
    member do
      resources :menu_items
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
