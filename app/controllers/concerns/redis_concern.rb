# frozen_string_literal: true

module RedisConcern
  extend ActiveSupport::Concern

  included do
    before_action :initialize
    before_action :get_stored_values
  end

  private

    def initialize
      @redis = Redis::Namespace.new("rate_limit", redis: Redis.new)
    end

    def get_stored_values
      @last_request_time = @redis.get("last_request_time")
      @last_retry_time = @redis.get("last_retry_time")
      @last_request_count = @redis.get("last_request_count").to_i
    end

    def reset_stored_values(request_time)
      @redis.set("last_request_time", request_time)
      @redis.set("last_retry_time", Time.now)
      @redis.set("last_request_count", 0)

      get_stored_values
    end
end
