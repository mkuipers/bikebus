redis_url = ENV.fetch("REDIS_URL") { "redis://localhost:6379/0" }

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }

  Sidekiq::Cron::Job.load_from_hash(
    "materialize_rides" => {
      "cron"  => "0 0 * * *",   # nightly at midnight UTC
      "class" => "MaterializeRidesJob"
    },
    "stale_leader_check" => {
      "cron"  => "* * * * *",   # every minute
      "class" => "StaleLeaderCheckJob"
    }
  )
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
