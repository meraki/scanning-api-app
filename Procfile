web: bundle exec unicorn -p $PORT -c ./unicorn.rb
worker: env QUEUE=jsonfiles TERM_CHILD=1 rake jobs:work
