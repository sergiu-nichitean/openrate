Rails.application.routes.draw do
  devise_for :users
  resources :custom_fields
  resources :tags
  resources :broadcasts
  resources :sequences
  resources :messages
  resources :subscribers
  resources :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'broadcast_filter_value_selector' => 'broadcasts#filter_value_selector'
  post 'broadcast_add_filter/:id' => 'broadcasts#add_filter'
  get 'broadcast_delete_filter/:id' => 'broadcasts#delete_filter'
  get 'settings' => 'settings#index'
  patch 'settings' => 'settings#save'

  get '/unsubscribe/:token/:message_id' => 'subscribers#unsubscribe'
  get '/cancel_unsubscribe/:token' => 'subscribers#cancel_unsubscribe'
  get '/submit_unsubscribe/:token/:message_id' => 'subscribers#submit_unsubscribe'
  get '/import_subscribers' => 'subscribers#import'
  post '/submit_import_subscribers' => 'subscribers#submit_import'
  get '/import_status/:id' => 'subscribers#import_status'

  get 'dashboard' => 'dashboard#index'

  root to: 'landing_page#index'
end
