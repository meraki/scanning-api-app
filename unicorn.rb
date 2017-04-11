worker_processes 3 
timeout 30
preload_app true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end
  
  if defined?(Resque)
    Resque.redis.quit
    Resque.logger.info('Disconnected from Redis')
  end
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end
  if defined?(Resque)
    Resque.redis = ENV['REDIS_URL']
    Resque.logger.info('Connected to Redis')
  end
end
