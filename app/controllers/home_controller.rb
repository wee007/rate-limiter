# frozen_string_literal: true

class HomeController < ApplicationController
  include RedisConcern

  def index
    if within_retry_period?
      result_message = retry_message_with(retry_period: calculate_elapsed_time)
      status = :too_many_requests
    else
      reset_stored_values(calculate_request_time) if request_period_elapsed?

      if @last_request_count > ENV["REQUEST_LIMIT"].to_i
        @redis.set("last_retry_time", calculate_retry_time)
        @redis.set("last_request_count", 0)

        result_message = retry_message_with(retry_period: ENV["RETRY_PERIOD"].to_i)
        status = :too_many_requests
      else
        @redis.set("last_request_count", increment_request_count)

        result_message = "ok"
        status = :ok
      end
    end

    render plain: result_message, status: status
  end

  private

    def within_retry_period?
      @last_retry_time && (Time.now < Time.parse(@last_retry_time))
    end

    def request_period_elapsed?
      @last_request_time.nil? || Time.now > Time.parse(@last_request_time)
    end

    def calculate_request_time
      Time.now + ENV["REQUEST_PERIOD"].to_i
    end

    def calculate_retry_time
      Time.now + ENV["RETRY_PERIOD"].to_i
    end

    def calculate_elapsed_time
      (Time.parse(@last_retry_time) - Time.now).to_i
    end

    def increment_request_count
      @last_request_count.to_i + 1
    end

    def retry_message_with(retry_period:)
      "Rate limit exceeded. Try again in #{retry_period} seconds"
    end
end
