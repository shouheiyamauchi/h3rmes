Rails.application.routes.draw do
  root 'pages#home'

  get 'pages/json'
  get 'pages/test'
  get 'pages/check_in'
  get 'pages/list_foods'
  get 'pages/list_categories'
  get 'pages/params_test'
  post 'pages/create_order'
  get 'pages/add_item'
  post 'pages/find_total'
  resources :orders

  devise_for :users, controllers: { registrations: 'users/registrations' }

  resources :menu_groups do
    member do
      resources :menu_items
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
