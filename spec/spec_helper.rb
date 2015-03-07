require 'bson'
require 'mongoid'
require 'factory_girl_rails'
require './lib/merge-mongoid.rb'
require './spec/factories.rb'
require './spec/helpers.rb'
MODELS = File.join(File.dirname(__FILE__), "models")
Dir["#{MODELS}/*.rb"].each { |f| require f }

Rspec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include Helpers
end

I18n.enforce_available_locales = false

Mongoid.configure do |config|
  config.connect_to("merge_mongoid_spec")
end

Bundler.require(:default)
