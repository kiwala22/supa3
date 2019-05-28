Rails.application.routes.draw do
   get 'gamers/index'
   get 'tickets/index'
   get 'tickets/new'
   get 'broadcasts/index'
   get 'broadcasts/new'
   get 'broadcasts/edit'
   get 'broadcasts/uodate'
   get 'broadcasts/delete'
   get 'analytics/index'

   devise_for :admin_users, ActiveAdmin::Devise.config
   ActiveAdmin.routes(self)
   devise_for :users
   devise_scope :user do
      root to: "devise/sessions#new"
   end
   authenticate :user do
      require 'sidekiq/web'
      mount Sidekiq::Web => '/sidekiq'
   end
   # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
