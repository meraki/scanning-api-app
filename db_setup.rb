require 'data_mapper'

# ---- Define data model ---------------

class Client
  include DataMapper::Resource

  property :id,         Serial                    # row key
  property :mac,        String,  :key => true
  property :seenString, String
  property :seenEpoch,  Integer, :default => 0, :index => true
  property :lat,        Float
  property :lng,        Float
  property :unc,        Float
  property :manufacturer, String
  property :os,         String
  property :ssid,       String
  property :floors,     String
  property :eventType,       String
end

# Heroku does not accept sqlite3 as a database, and we use postgresql instead
# Run 'heroku addons:create heroku-postgresql:hobby-dev' to 
# create the postgres database for Heroku
# To scale up, replace 'hobby-dev' with any other database plans found in heroku at:
# https://elements.heroku.com/addons/heroku-postgresql
# This creates the database, and sets the environment variable 'DATABASE_URL'
# which contains the URL to connect to the postgresql database

# ---- Setup the database --------------

if ENV['DATABASE_URL']
  db = ENV['DATABASE_URL']
else
  db = "sqlite:memory:"
end

DataMapper.setup(:default, db)

DataMapper.finalize
