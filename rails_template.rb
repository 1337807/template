def migrate
  rake "db:migrate"
  rake "db:test:prepare"
end

def prepend_file(filename, line)
  contents = File.read(filename)
  File.write(filename, "#{line}\n" + contents)
end

run "psql -U jonan --command='set role admin; create role test_app with createdb; alter role test_app with login'"

['test', 'development', 'production'].each do |environment|
  run "createdb -U test_app test_app_#{environment}"
end

gem "devise"
gem "cancan"

gem_group :development, :test do
  gem "capybara"
  gem "poltergeist"
  gem "rspec-rails"
  gem "guard-rspec"
end

run "bundle install"
run "rails g devise:install"
run "rails g devise User"
run "rails g rspec:install"

prepend_file('spec/spec_helper.rb', <<capybara)
require 'capybara/rspec'
require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist
capybara

migrate
