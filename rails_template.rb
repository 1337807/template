def migrate
  rake "db:migrate"
  rake "db:test:prepare"
end

def prepend_file(filename, line)
  contents = File.read(filename)
  File.write(filename, "#{line}\n" + contents)
end

def append_to_file(filename, line)
  contents = File.read(filename)
  File.write(filename, contents + "\n#{line}\n")
end

run "psql -U jonan --command='set role admin; create role #{@app_name} with createdb; alter role #{@app_name} with login'"

['test', 'development', 'production'].each do |environment|
  run "createdb -U #{@app_name} #{@app_name}_#{environment}"
end

gem "devise"
gem "cancan"
gem "bootstrap-sass"

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
run "mkdir spec/features"

append_to_file('app/assets/stylesheets/application.css', '@import "bootstrap";')
run "mv app/assets/stylesheets/application.css app/assets/stylesheets/application.css.scss"

migrate
