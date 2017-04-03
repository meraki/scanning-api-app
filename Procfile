web: bundle exec unicorn -p $PORT -c ./unicorn.rb
worker: env COUNT=5 QUEUE=jsonfiles TERM_CHILD=1 rake jobs:work
