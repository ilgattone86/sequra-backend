ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require 'rspec/rails'
require 'shoulda/matchers'
require 'database_cleaner/active_record'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end
  config.include(Shoulda::Matchers::ActiveModel, type: :model)
  config.include(Shoulda::Matchers::ActiveRecord, type: :model)
end
