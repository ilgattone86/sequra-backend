ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require 'rspec/rails'
require 'shoulda/matchers'

RSpec.configure do |config|
  config.include(Shoulda::Matchers::ActiveModel, type: :model)
  config.include(Shoulda::Matchers::ActiveRecord, type: :model)
end
