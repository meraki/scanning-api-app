source 'https://rubygems.org'
ruby '2.5.1'
gem 'json'
gem 'sinatra'
gem 'iconv', '~> 1.0.3'
gem 'unicorn'
gem 'datamapper', '1.0'
gem 'redis', '<4'
gem 'resque'

group :production do
  gem "pg"
  gem "dm-postgres-adapter"
end

group :development, :test do
  gem "sqlite3"
  gem "dm-sqlite-adapter"
end
