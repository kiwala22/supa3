# config valid for current version and patch releases of Capistrano
lock "~> 3.16.0"

set :application, "SupaAI"
set :repo_url, "git@bitbucket.org:skylinesmslimited/supa_ai.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
set :scm, :git

set :ssh_options, {:forward_agent => true, port: 2022}

set :deploy_via, :copy

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
set :pty, true

set :passenger_restart_with_touch, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml', '.env', 'config/initializers/sidekiq.rb')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/reports')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

# rvm
set :rvm_type, :system                     # Defaults to: :auto
set :rvm_ruby_version, '2.4.0'      # Defaults to: 'default'
set :rvm_custom_path, '/home/admin/.rvm'  # only needed if not detected

#Passenger rvm
set :passenger_rvm_ruby_version, '2.4.0'

namespace :deploy do

 after :restart, :clear_cache do
   on roles(:web), in: :groups, limit: 3, wait: 10 do
     # Here we can do anything such as:
     # within release_path do
     #   execute :rake, 'cache:clear'
     # end
   end
 end

end
