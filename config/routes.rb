Rails.application.routes.draw do


   resources :broadcasts, only: [:index, :new, :create]
   resources :gamers, only: [:new, :index, :create]
   resources :tickets, only: [:index, :new, :create]
   match 'analytics' => "analytics#index", via: [:get]

   devise_for :admin_users, ActiveAdmin::Devise.config
   ActiveAdmin.routes(self)
   devise_for :users
   devise_scope :user do
      authenticated :user do
         root :to => 'analytics#index', as: :authenticated_root
      end
      unauthenticated :user do
         root to: "devise/sessions#new"
      end
   end
   authenticate :user do
      require 'sidekiq/web'
      mount Sidekiq::Web => '/sidekiq'
   end
   # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
