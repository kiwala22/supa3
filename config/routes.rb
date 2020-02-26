Rails.application.routes.draw do
   resources :push_pay_broadcasts, only: [:new, :index, :create]
   resources :payments, only: [:new, :index, :update, :create]
   resources :reports, only: [:index]
   match "download_report" => "reports#download_report", via: [:get]
   namespace :confirmation do
      match 'mtn/payment' => 'mtn_uganda#create', via: [:post, :get]
      match 'airtel' => 'airtel_uganda#create', via: [:post, :get]
      match 'airtel/merchant_pay' => 'airtel_merchant_pay#create', via: [:post, :get]
   end
   get '/api_user_keys/:id', to: 'api_users#generate_api_keys', as: 'user_keys'
   resources :api_users, only: [:new, :index, :create]
   resources :bulks
   resources :broadcasts
   resources :collections, only: [:index, :update]
   resources :disbursements, only: [:index]
   resources :draw_offers
   resources :gamers, only: [:index]
   resources :tickets, only: [:index, :update]
   resources :draws, only: [:index]
   match 'jackpot' => "jackpot#index", via: [:get, :post]
   match 'jackpot_draws' => "jackpot#draws", via: [:get, :post]
   match 'download_tickets' => "jackpot#download_tickets", via: [:get, :post]
   match 'analytics' => "analytics#index", via: [:get]
   match 'revenues' => "revenues#index", via: [:get]
   match 'comparisons' => "comparisons#index", via: [:get]
   match 'ticket_analytics' => "ticket_analytics#index", via: [:get]
   match 'process_broadcasts' => "auto_jobs#process_broadcasts", via: [:post]
   match 'run_predictions' => "auto_jobs#run_predictions", via: [:post]
   match 'update_segments' => "auto_jobs#update_segments", via: [:post]
   match 'update_user_info' => "auto_jobs#update_user_info", via: [:post]
   match 'run_daily_reports' => "auto_jobs#generate_daily_reports", via: [:post]
   match 'run_draws' => "auto_jobs#run_draws", via: [:post]
   match 'create_gamers' => "auto_jobs#create_gamers", via: [:post]
   match 'update_tickets' => "auto_jobs#update_tickets", via: [:post]
   match 'update_results' => "auto_jobs#update_results", via: [:post]
   match 'balance_notification' => "auto_jobs#low_credit_notification", via: [:post]


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
   require 'sidekiq/web'
   mount Sidekiq::Web => '/rabbit'
   # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
