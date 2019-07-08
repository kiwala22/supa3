require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SupaAi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    #setup bower components folder for lookup
     config.assets.paths << Rails.root.join('vendor', 'assets', 'bower_components')
     # fonts
     config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/
     # images
     config.assets.precompile << /\.(?:png|jpg)$/
     # # precompile vendor assets
     # config.assets.precompile += %w( base.js )
     # config.assets.precompile += %w( base.css )

     # Add the fonts path
     config.assets.paths << Rails.root.join('app', 'assets', 'fonts')

    config.time_zone = 'Nairobi'
    config.active_record.default_timezone = :local
  end
end
