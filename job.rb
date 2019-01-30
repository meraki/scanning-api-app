require 'digest'
require 'resque'
require 'json'
require_relative 'db_setup'

if ENV['REDIS_URL']
  Resque.redis = Redis.new(url: ENV['REDIS_URL'])
  Resque.logger = Logger.new($stdout)
  Resque.logger.level = Logger::WARN
else
  puts "Environment variable REDIS_URL required"
  exit 1
end

SECRET = ENV['SECRET']
HASH_KEY = ENV['HASH_KEY'] ? ENV['HASH_KEY'] : nil

# Resque job to parse incoming JSON and create/update database rows
class LocationData
  @queue = :jsonfiles
  def self.perform(request)
    logger = Logger.new(STDOUT)
    map = JSON.parse(request)
    if map['secret'] != SECRET
      logger.warn "got post with bad secret: #{map['secret']}"
      return
    end
    logger.info "version is #{map['version']}"
    if map['version'] != '2.0'
      logger.warn "got post with unexpected version: #{map['version']}"
      return
    end
    if map['type'] != 'DevicesSeen' && map['type'] != 'BluetoothDevicesSeen' 
      logger.warn "got post for event that we're not interested in: #{map['type']}"
      return
    end
    map['data']['observations'].each do |c|
      loc = c['location']
      next if loc == nil
      if HASH_KEY
        name = Digest::SHA256.hexdigest(c['clientMac']+HASH_KEY)[-12..-1].scan(/\w{2}/).join(":")
      else
        name = c['clientMac']
      end
      lat = loc['lat']
      lng = loc['lng']
      seenString = c['seenTime']
      seenEpoch = c['seenEpoch']
      floors = map['data']['apFloors'] == nil ? "" : map['data']['apFloors'].join
      tags = map['data']['apTags'] == nil ? "" : map['data']['apTags'].join
      logger.info "AP #{map['data']['apMac']} on #{map['data']['apFloors']}: #{c}"
      next if (seenEpoch == nil || seenEpoch == 0)  # This probe is useless, so ignore it
      client = Client.first_or_create(:mac => name)
      if (seenEpoch > client.seenEpoch)             # If client was created, this will always be true
        client.attributes = { :lat => lat, :lng => lng,
                              :seenString => seenString, :seenEpoch => seenEpoch,
                              :unc => loc['unc'],
                              :manufacturer => c['manufacturer'], :os => c['os'],
                              :ssid => c['ssid'],
                              :floors => floors,
                              :eventType => map['type'],
                              :tags => tags
                            }
        client.save
      end
    end
  rescue Resque::TermException
    Resque.enqueue(self, request)
  end
end
