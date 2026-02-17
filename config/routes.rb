Rails.application.routes.draw do
  # Η αρχική σελίδα δείχνει τις αναρτήσεις
  root "posts#index"
resources :posts do
  resources :comments, only: [:create, :destroy]
  collection { get :search }
end
  # Ρυθμίσεις για το Devise (Login/Register) και Google Auth
  devise_for :users, controllers: { 
    omniauth_callbacks: 'users/omniauth_callbacks' 
  }

  # Πλήρεις λειτουργίες για τα Posts (Create, Edit, Delete, View)
 

  # Λειτουργίες για τις Επαφές
  resources :contacts, only: [:index, :create, :destroy]
  
  # Λειτουργίες για το Chat (Μηνύματα)
  resources :messages, only: [:index, :show, :create]

 resources :notifications, only: [:index] do
  member do
    patch :mark_as_read
  end
  collection do
    patch :mark_all_as_read
  end
end
  # Health check για την εφαρμογή
  get "up" => "rails/health#show", as: :rails_health_check
end