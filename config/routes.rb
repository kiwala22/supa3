Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
   devise_for :users
   authenticate :user do
      require 'sidekiq/web'
      mount Sidekiq::Web => '/sidekiq'
   end
   # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
