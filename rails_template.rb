def migrate
  rake "db:migrate"
  rake "db:test:prepare"
end

def prepend_file(filename, line)
  contents = File.read(filename)
  File.write(filename, "#{line}\n" + contents)
end

run "psql -U jonan --command='set role admin; create role #{@app_name} with createdb; alter role #{@app_name} with login'"

['test', 'development', 'production'].each do |environment|
  run "createdb -U #{@app_name} #{@app_name}_#{environment}"
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
generate 'devise:install'
generate 'devise User'
generate 'rspec:install'

prepend_file('spec/spec_helper.rb', <<capybara)
require 'capybara/rspec'
require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist
capybara

migrate
