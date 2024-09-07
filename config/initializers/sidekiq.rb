sidekiq_redis_url = { url: ENV.fetch('REDIS_URL', nil) }

Sidekiq.configure_server do |config|
  config.redis = sidekiq_redis_url
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_redis_url
end
