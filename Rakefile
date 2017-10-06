require 'resque/tasks'
require_relative 'job'

desc "Alias for resque:work (for Heroku)"
task "jobs:work" => "resque:work"

# WARNING: This task is for the scanning api demo app only.
desc "Periodically empty heroku database"
task :empty_database do
  puts "Dropping all rows"
  Client.destroy
end
