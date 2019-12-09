Rails.application.routes.draw do


  resources :bulks
   resources :broadcasts
   resources :gamers, only: [:new, :index, :create]
   resources :tickets, only: [:index, :new]
   resources :draws, only: [:index]
   match 'tickets' => "tickets#create", via: [:post], :defaults => { :format => 'json' }
   match 'analytics' => "analytics#index", via: [:get]
   match 'revenues' => "revenues#index", via: [:get]
   match 'comparisons' => "comparisons#index", via: [:get]
   match 'ticket_analytics' => "ticket_analytics#index", via: [:get]
   match 'process_broadcasts' => "auto_jobs#process_broadcasts", via: [:post]
   match 'run_predictions' => "auto_jobs#run_predictions", via: [:post]
   match 'update_segments' => "auto_jobs#update_segments", via: [:post]
   match 'run_draws' => "auto_jobs#run_draws", via: [:post]

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
