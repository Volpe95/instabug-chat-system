$redis = Redis::Namespace.new('chatsystem', redis: Redis.new(host: ENV['REDIS_HOST']))
