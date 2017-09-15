# encoding: utf-8

$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require "pages_core/version"

Gem::Specification.new do |s|
  s.name        = "pages_core"
  s.version     = PagesCore::VERSION
  s.authors     = ["Inge Jørgensen"]
  s.email       = ["inge@kord.no"]
  s.homepage    = ""
  s.summary     = "Pages Core"
  s.description = "Pages Core"

  s.rubyforge_project = "."

  s.required_ruby_version = ">= 1.9.2"

  s.files = Dir[
    "{app,config,db,lib,vendor}/**/*",
    "Rakefile",
    "README.md",
    "template.rb"
  ]

  s.add_development_dependency "mysql2", "~> 0.4.2"
  s.add_development_dependency "pg", "~> 0.18.3"
  s.add_development_dependency "rspec-rails", "~> 3.5.1"
  s.add_development_dependency "capybara", "~> 2.15.0"
  s.add_development_dependency "factory_girl", "~> 4.7.0"
  s.add_development_dependency "shoulda-matchers", "~> 3.1.1"
  s.add_development_dependency "timecop", "~> 0.8.0"
  s.add_development_dependency "rails-controller-testing", "~> 1.0.0"

  s.add_dependency "rails", "~> 5.0"

  s.add_dependency "bcrypt-ruby"
  s.add_dependency "RedCloth", "~> 4.3.2"
  s.add_dependency "dis", "~> 1.0"
  s.add_dependency "dynamic_image", "~> 2.0"
  s.add_dependency "actionpack-page_caching", "~> 1.1.0"
  s.add_dependency "active_model_serializers", "~> 0.9.0"
  s.add_dependency "country_select"

  # Locales
  s.add_dependency "rails-i18n", "~> 5.0.0"

  # Default asset dependencies
  s.add_dependency "sass-rails", "~> 5.0"
  s.add_dependency "uglifier", ">= 1.3.0"
  s.add_dependency "coffee-rails", "~> 4.2"
  s.add_dependency "jquery-rails"
  s.add_dependency "jbuilder", "~> 2.5"

  # Extra asset dependencies
  s.add_dependency "jquery-ui-rails", "~> 5.0.0"
  s.add_dependency "jcrop-rails-v2"
  s.add_dependency "underscore-rails"
  s.add_dependency "font-awesome-rails", "~> 4.7"
  s.add_dependency "react-rails", "~> 2.2.1"

  # ActiveRecord extensions
  s.add_dependency "acts_as_list", "~> 0.9"
  s.add_dependency "localizable_model", ">= 0.5.3"

  # Delayed Job
  s.add_dependency "delayed_job", "~> 4.1.2"
  s.add_dependency "delayed_job_active_record", "~> 4.1.1"
  s.add_dependency "daemons", "~> 1.2.0"
end
